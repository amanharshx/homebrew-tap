class VisionExportStudio < Formula
  desc "Desktop app for exporting vision models"
  homepage "https://github.com/amanharshx/vision-export-studio"
  url "https://github.com/amanharshx/vision-export-studio/releases/download/v0.1.12/vision-export-studio-linux-x86_64.tar.gz"
  version "0.1.12"
  sha256 "9f34155b00108a1e80bc902205da198c3f57e68981405c52280960d87c42e53c"
  license "MIT"

  depends_on :linux

  def install
    root_dir = buildpath.children.find do |path|
      path.directory? && (path/"bin/vision-export-studio").exist?
    end

    root_dir ||= begin
      root_dirs = buildpath.children.select(&:directory?)
      payload_dirs = root_dirs.select { |path| (path/"bin").directory? || (path/"share").directory? }
      payload_dirs.one? ? payload_dirs.first : buildpath
    end

    odie "missing bin/vision-export-studio in extracted payload" unless (root_dir/"bin/vision-export-studio").exist?

    appimage_path = libexec/"libexec/vision-export-studio.AppImage"
    libexec.install root_dir.children
    (bin/"vision-export-studio").write <<~SH
      #!/bin/sh
      exec "#{appimage_path}" "$@"
    SH
    (share/"applications").install libexec/"share/applications/vision-export-studio.desktop"
    (share/"icons/hicolor/256x256/apps").install libexec/"share/icons/hicolor/256x256/apps/vision-export-studio.png"
    prefix.install_metafiles
  end

  test do
    wrapper_link = bin/"vision-export-studio"
    appimage_path = libexec/"libexec/vision-export-studio.AppImage"
    desktop_path = share/"applications/vision-export-studio.desktop"
    icon_path = share/"icons/hicolor/256x256/apps/vision-export-studio.png"

    assert_path_exists wrapper_link
    assert_path_exists appimage_path
    assert_path_exists desktop_path
    assert_path_exists icon_path
  end
end
