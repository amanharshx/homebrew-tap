#!/usr/bin/env python3
"""Offline tests for update_tap.py.

Run with:  python3 .github/scripts/test_update_tap.py

The network-dependent SHA download is monkeypatched so these tests stay
hermetic. They lock the regex/rewrite behavior for the three supported shapes
plus a negative case before future apps stretch the parser.
"""
from __future__ import annotations

import importlib.util
import os
import pathlib
import tempfile
import textwrap
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("update_tap", os.path.join(HERE, "update_tap.py"))
u = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(u)

A64 = "a" * 64
C64 = "c" * 64
D64 = "d" * 64
E64 = "e" * 64
ZERO = "0" * 64


def fake_sha(url: str, **_kwargs: object) -> str:
    """Deterministic stand-in for sha256_of_url, keyed on the asset URL."""
    if "aarch64" in url:
        return A64
    if "linux-x86_64" in url:
        return E64
    if "x64" in url:
        return C64
    return D64


class UpdateTapTests(unittest.TestCase):
    def setUp(self) -> None:
        self._orig_sha = u.sha256_of_url
        u.sha256_of_url = fake_sha
        self._tmp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self._tmp.name)
        (self.root / "Casks").mkdir()
        (self.root / "Formula").mkdir()

    def tearDown(self) -> None:
        u.sha256_of_url = self._orig_sha
        self._tmp.cleanup()

    def _write(self, rel: str, body: str) -> pathlib.Path:
        path = self.root / rel
        path.write_text(textwrap.dedent(body).lstrip("\n"))
        return path

    def test_dual_arch_cask(self) -> None:
        path = self._write(
            "Casks/demo-dual.rb",
            f"""
            cask "demo-dual" do
              arch arm: "aarch64", intel: "x64"

              version "1.0.0"
              sha256 arm:   "{ZERO}",
                     intel: "{ZERO}"

              url "https://github.com/me/demo/releases/download/v#{{version}}/Demo_#{{version}}_#{{arch}}.dmg"
              name "Demo"
            end
            """,
        )
        u.update_file(path, "2.0.0")
        out = path.read_text()
        self.assertIn('version "2.0.0"', out)
        self.assertIn(f'sha256 arm:   "{A64}"', out)
        self.assertIn(f'intel: "{C64}"', out)
        # URL stays interpolated.
        self.assertIn("v#{version}/Demo_#{version}_#{arch}.dmg", out)

    def test_single_file_cask(self) -> None:
        path = self._write(
            "Casks/demo-single.rb",
            f"""
            cask "demo-single" do
              version "1.0.0"
              sha256 "{ZERO}"

              url "https://github.com/me/demo/releases/download/v#{{version}}/Demo.zip"
              name "Demo"
            end
            """,
        )
        u.update_file(path, "2.0.0")
        out = path.read_text()
        self.assertIn('version "2.0.0"', out)
        self.assertIn(f'sha256 "{D64}"', out)
        self.assertIn("v#{version}/Demo.zip", out)

    def test_linux_formula_literal_version(self) -> None:
        path = self._write(
            "Formula/demo.rb",
            f"""
            class Demo < Formula
              desc "x"
              homepage "https://github.com/me/demo"
              url "https://github.com/me/demo/releases/download/v1.0.0/demo-linux-x86_64.tar.gz"
              version "1.0.0"
              sha256 "{ZERO}"
              license "MIT"
            end
            """,
        )
        u.update_file(path, "2.0.0")
        out = path.read_text()
        self.assertIn('version "2.0.0"', out)
        self.assertIn(f'sha256 "{E64}"', out)
        self.assertIn("/download/v2.0.0/demo-linux-x86_64.tar.gz", out)
        self.assertNotIn("v1.0.0", out)

    def test_unrecognized_literal_url_fails_loud(self) -> None:
        path = self._write(
            "Formula/demo-bad.rb",
            f"""
            class DemoBad < Formula
              desc "x"
              homepage "https://github.com/me/demo"
              url "https://example.com/demo/latest/demo.tar.gz"
              version "1.0.0"
              sha256 "{ZERO}"
              license "MIT"
            end
            """,
        )
        with self.assertRaises(SystemExit):
            u.update_file(path, "2.0.0")

    def test_reproduce_same_version_is_noop(self) -> None:
        body = f"""
        class Demo < Formula
          desc "x"
          homepage "https://github.com/me/demo"
          url "https://github.com/me/demo/releases/download/v1.0.0/demo-linux-x86_64.tar.gz"
          version "1.0.0"
          sha256 "{E64}"
          license "MIT"
        end
        """
        path = self._write("Formula/demo-same.rb", body)
        before = path.read_text()
        u.update_file(path, "1.0.0")
        self.assertEqual(before, path.read_text())


if __name__ == "__main__":
    unittest.main(verbosity=2)
