class Clipfit < Formula
  include Language::Python::Virtualenv

  desc "Shrink clipboard images to fit LLM chats (fewer pixels, fewer tokens)"
  homepage "https://github.com/amanharshx/clipfit"
  url "https://github.com/amanharshx/clipfit/archive/refs/tags/v0.3.0.tar.gz"
  version "0.3.0"
  sha256 "a05ea9446bc47703951a6d3c2f8d936271510ba466be71e639f87eef15001862"
  license "MIT"

  depends_on "python@3.12"
  depends_on "skhd"

  # Prebuilt wheels (no compilation): install is seconds on any Mac.
  # pyobjc wheels are universal2 (one file for both arches); Pillow is per-arch.
  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/86/b2/bbf7f049880ab40d110e66f25122342a1f6c98d6fe3c59bb98985503c660/pyobjc_core-12.2.2-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "122e6ad302a2abf5d4d4adb0156db751600ddf2768441696cba17b31323085e7"
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/fd/2f/b67e73d8bc367e03fe7861cd9c49fff9dcfa6db83bc0630c0adcfb25b7fa/pyobjc_framework_cocoa-12.2.2-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "e106f395531e67694376b0f1184612cbeea3ec8b9bf56b55ef41d026171d2a2d"
  end

  resource "pillow" do
    on_arm do
      url "https://files.pythonhosted.org/packages/d8/66/9a386a92561f402389a4fc70c18838bf6d35eb5eb5c6850b4b2dc64f5048/pillow-12.3.0-cp312-cp312-macosx_11_0_arm64.whl"
      sha256 "ffd0c5368496f41b0944be820fcb7a838aa6e623d250b01acf2643939c3f99d7"
    end
    on_intel do
      url "https://files.pythonhosted.org/packages/37/bf/fb3ebff8ddcb76aac5a01389251bbbb9519922a9b520d8247c1ca864a25d/pillow-12.3.0-cp312-cp312-macosx_10_13_x86_64.whl"
      sha256 "ba09209fbe443b4acccebe845d8a138b89a8f4fbaeedd44953490b5315d5e965"
    end
  end

  def install
    venv = virtualenv_create(libexec, "python3.12")
    # Homebrew caches downloads with a "<sha>--" filename prefix that pip won't
    # accept as a wheel name, so copy each to its canonical filename first.
    wheels = resources.map do |r|
      dest = buildpath/File.basename(r.url)
      cp r.cached_download, dest
      dest
    end
    # The venv is created --without-pip, so drive pip from the brewed python
    # with --python pointing at the venv (this is how Homebrew installs too).
    system "python3.12", "-m", "pip", "--python=#{libexec}/bin/python", "install",
           "--no-deps", "--no-index", *wheels
    # clipfit itself is pure Python; its deps are already in the venv.
    venv.pip_install_and_link buildpath
  end

  test do
    assert_match "clipfit #{version}", shell_output("#{bin}/clipfit --version")
  end
end
