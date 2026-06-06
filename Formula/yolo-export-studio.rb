class YoloExportStudio < Formula
  desc "Desktop app for exporting Ultralytics YOLO models"
  homepage "https://github.com/amanharshx/yolo-export-studio"
  url "https://github.com/amanharshx/yolo-export-studio/releases/download/v0.1.2/yolo-export-studio-linux-x86_64.tar.gz"
  version "0.1.2"
  sha256 "2eaeac16ae66decda9df47ccea90d7ded97e2986854d14d9b70214da51be86d1"
  license "MIT"

  depends_on :linux

  def install
    root_dir = buildpath.children.find do |path|
      path.directory? && (path/"bin/yolo-export-studio").exist?
    end

    root_dir ||= begin
      root_dirs = buildpath.children.select(&:directory?)
      payload_dirs = root_dirs.select { |path| (path/"bin").directory? || (path/"share").directory? }
      payload_dirs.one? ? payload_dirs.first : buildpath
    end

    odie "missing bin/yolo-export-studio in extracted payload" unless (root_dir/"bin/yolo-export-studio").exist?

    appimage_path = libexec/"libexec/yolo-export-studio.AppImage"
    libexec.install root_dir.children
    (bin/"yolo-export-studio").write <<~SH
      #!/bin/sh
      exec "#{appimage_path}" "$@"
    SH
    (share/"applications").install libexec/"share/applications/yolo-export-studio.desktop"
    (share/"icons/hicolor/256x256/apps").install libexec/"share/icons/hicolor/256x256/apps/yolo-export-studio.png"
    prefix.install_metafiles
  end

  test do
    wrapper_link = bin/"yolo-export-studio"
    appimage_path = libexec/"libexec/yolo-export-studio.AppImage"
    desktop_path = share/"applications/yolo-export-studio.desktop"
    icon_path = share/"icons/hicolor/256x256/apps/yolo-export-studio.png"

    assert_path_exists wrapper_link
    assert_path_exists appimage_path
    assert_path_exists desktop_path
    assert_path_exists icon_path
  end
end
