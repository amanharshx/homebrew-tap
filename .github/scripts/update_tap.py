#!/usr/bin/env python3
"""Update a Homebrew cask and/or formula in this tap for a new release.

The script is intentionally self-contained: it derives the download URLs from
the `url` line already present in the cask/formula file, substitutes the new
version (and architecture, for casks), downloads each artifact, computes its
SHA-256, and rewrites the `version`, `url`, and `sha256` fields in place.

Because the URL template lives in the formula/cask file, a product repo only
needs to tell this script the new version and which file(s) to touch. No
asset-name templates or per-app configuration are passed in.

Supported shapes:

1. Dual-arch DMG cask (arch arm:/intel: with `sha256 arm:`/`intel:`):

       arch arm: "aarch64", intel: "x64"
       version "0.1.5"
       sha256 arm:   "<hex>",
              intel: "<hex>"
       url "https://.../v#{version}/Name_#{version}_#{arch}.dmg"

2. Single-file cask (one top-level `sha256`):

       version "1.0.0"
       sha256 "<hex>"
       url "https://.../v#{version}/Name.zip"

3. Single-URL formula (one top-level `sha256`, version may be literal in url):

       url "https://.../v0.1.5/name-linux-x86_64.tar.gz"
       version "0.1.5"
       sha256 "<hex>"
"""
from __future__ import annotations

import argparse
import hashlib
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.request

USER_AGENT = "amanharshx-homebrew-tap-updater"
HEX64 = r"[0-9a-fA-F]{64}"

VERSION_RE = re.compile(r'(?P<prefix>^\s*version\s+")(?P<value>[^"]+)(?P<suffix>")', re.MULTILINE)
URL_RE = re.compile(r'(?P<prefix>^\s*url\s+")(?P<value>[^"]+)(?P<suffix>")', re.MULTILINE)
ARCH_RE = re.compile(r'arch\s+arm:\s*"(?P<arm>[^"]+)",\s*intel:\s*"(?P<intel>[^"]+)"')
SINGLE_SHA_RE = re.compile(rf'(?P<prefix>^\s*sha256\s+")(?P<hex>{HEX64})(?P<suffix>")', re.MULTILINE)
DUAL_SHA_RE = re.compile(
    rf'(?P<prefix>sha256\s+arm:\s*")(?P<arm>{HEX64})'
    rf'(?P<middle>"\s*,\s*\n\s*intel:\s*")(?P<intel>{HEX64})'
    rf'(?P<suffix>")'
)


def fail(message: str) -> "NoReturn":  # type: ignore[name-defined]
    raise SystemExit(f"error: {message}")


def sha256_of_url(url: str, *, retries: int = 40, delay: int = 15) -> str:
    """Download `url` and return its SHA-256, retrying while assets propagate."""
    headers = {"User-Agent": USER_AGENT}
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://github.com/"):
        headers["Authorization"] = f"Bearer {token}"

    last_error: Exception | None = None
    for attempt in range(1, retries + 1):
        request = urllib.request.Request(url, headers=headers)
        try:
            digest = hashlib.sha256()
            with urllib.request.urlopen(request) as response:
                while chunk := response.read(1024 * 1024):
                    digest.update(chunk)
            return digest.hexdigest()
        except urllib.error.HTTPError as exc:
            last_error = exc
            if exc.code not in (403, 404):
                fail(f"failed to download {url}: HTTP {exc.code}")
        except urllib.error.URLError as exc:
            last_error = exc
        if attempt < retries:
            print(
                f"asset not ready ({url}); attempt {attempt}/{retries}, waiting {delay}s...",
                file=sys.stderr,
            )
            time.sleep(delay)
    fail(f"gave up downloading {url} after {retries} attempts ({last_error})")


def replace_version_segment(url: str, old_version: str, new_version: str) -> tuple[str, int]:
    """Replace `old_version` only where it appears as a delimited path/filename segment.

    Matches forms like `/v1.2.3/`, `/1.2.3/`, `_1.2.3_`, `-1.2.3-`, and
    `_1.2.3.` / `-1.2.3.` (version before a file extension), with an optional
    leading `v`. Returns the rewritten URL and the number of replacements made
    so callers can fail loudly when nothing matched.
    """
    pattern = re.compile(r"(?P<lead>[/_-]v?)" + re.escape(old_version) + r"(?P<trail>[/_.\-]|$)")
    return pattern.subn(lambda m: f'{m.group("lead")}{new_version}{m.group("trail")}', url)


def resolve_url(
    template: str,
    new_version: str,
    old_version: str,
    arch_value: str | None,
    path: pathlib.Path,
) -> str:
    """Resolve a concrete download URL from a cask/formula `url` template."""
    if "#{version}" in template:
        resolved = template.replace("#{version}", new_version)
    else:
        resolved, count = replace_version_segment(template, old_version, new_version)
        if count == 0:
            fail(
                f"{path}: url has no `#{{version}}` and no recognizable version segment "
                f"(e.g. /v{old_version}/) to substitute; refusing to guess"
            )
    if arch_value is not None:
        resolved = resolved.replace("#{arch}", arch_value)
    return resolved


def read_version(text: str, path: pathlib.Path) -> str:
    match = VERSION_RE.search(text)
    if not match:
        fail(f"{path}: could not find a `version \"...\"` line")
    return match.group("value")


def read_url_template(text: str, path: pathlib.Path) -> tuple[str, re.Match[str]]:
    match = URL_RE.search(text)
    if not match:
        fail(f"{path}: could not find a `url \"...\"` line")
    return match.group("value"), match


def update_version(text: str, new_version: str) -> str:
    return VERSION_RE.sub(
        lambda m: f'{m.group("prefix")}{new_version}{m.group("suffix")}',
        text,
        count=1,
    )


def update_url_literal_version(
    text: str, old_version: str, new_version: str, path: pathlib.Path
) -> str:
    match = URL_RE.search(text)
    if not match:
        return text
    value = match.group("value")
    if "#{version}" in value or old_version == new_version:
        # Interpolated URLs (or a no-op version) need no literal rewrite.
        return text
    new_value, count = replace_version_segment(value, old_version, new_version)
    if count == 0:
        fail(
            f"{path}: url has no recognizable version segment (e.g. /v{old_version}/) "
            f"to bump from {old_version} to {new_version}; refusing to guess"
        )
    return text[: match.start("value")] + new_value + text[match.end("value") :]


def update_file(path: pathlib.Path, new_version: str) -> None:
    if not path.exists():
        fail(f"{path} does not exist (cask/formula must be created manually first)")

    text = path.read_text()
    old_version = read_version(text, path)
    url_template, _ = read_url_template(text, path)

    is_dual = DUAL_SHA_RE.search(text) is not None

    if is_dual:
        arch_match = ARCH_RE.search(text)
        if not arch_match:
            fail(f"{path}: dual-arch sha256 found but no `arch arm: ..., intel: ...` line")
        arm_arch = arch_match.group("arm")
        intel_arch = arch_match.group("intel")

        arm_url = resolve_url(url_template, new_version, old_version, arm_arch, path)
        intel_url = resolve_url(url_template, new_version, old_version, intel_arch, path)
        arm_sha = sha256_of_url(arm_url)
        intel_sha = sha256_of_url(intel_url)

        if len(DUAL_SHA_RE.findall(text)) != 1:
            fail(f"{path}: expected exactly one dual-arch sha256 block")

        text = update_version(text, new_version)
        text = update_url_literal_version(text, old_version, new_version, path)
        text = DUAL_SHA_RE.sub(
            lambda m: (
                f'{m.group("prefix")}{arm_sha}{m.group("middle")}{intel_sha}{m.group("suffix")}'
            ),
            text,
            count=1,
        )
        print(f"{path.name}: arm   {arm_sha}  {arm_url}")
        print(f"{path.name}: intel {intel_sha}  {intel_url}")
    else:
        # Only the main artifact's sha256 (before any `resource` block) is
        # managed here. Resource checksums (e.g. pinned wheels) are updated by
        # hand, so we splice the file into head/tail around the first resource.
        resource_match = re.search(r'^\s*resource\s+"', text, re.MULTILINE)
        head_end = resource_match.start() if resource_match else len(text)
        head, tail = text[:head_end], text[head_end:]

        if len(SINGLE_SHA_RE.findall(head)) != 1:
            fail(
                f"{path}: expected exactly one top-level `sha256 \"...\"` line "
                "before any resource block"
            )
        asset_url = resolve_url(url_template, new_version, old_version, None, path)
        digest = sha256_of_url(asset_url)

        head = update_version(head, new_version)
        head = update_url_literal_version(head, old_version, new_version, path)
        head = SINGLE_SHA_RE.sub(
            lambda m: f'{m.group("prefix")}{digest}{m.group("suffix")}',
            head,
            count=1,
        )
        text = head + tail
        print(f"{path.name}: {digest}  {asset_url}")

    path.write_text(text)
    print(f"updated {path} -> {new_version}")


def normalize_version(value: str) -> str:
    return value[1:] if value.startswith("v") else value


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="New release version (with or without leading v)")
    parser.add_argument("--cask", help="Cask name to update (Casks/<name>.rb)")
    parser.add_argument("--formula", help="Formula name to update (Formula/<name>.rb)")
    parser.add_argument(
        "--tap-root",
        default=".",
        help="Path to the tap repository root (defaults to current directory)",
    )
    args = parser.parse_args()

    if not args.cask and not args.formula:
        fail("provide at least one of --cask or --formula")

    version = normalize_version(args.version)
    if not version:
        fail("version is empty after stripping leading v")

    root = pathlib.Path(args.tap_root)

    if args.cask:
        update_file(root / "Casks" / f"{args.cask}.rb", version)
    if args.formula:
        update_file(root / "Formula" / f"{args.formula}.rb", version)

    return 0


if __name__ == "__main__":
    sys.exit(main())
