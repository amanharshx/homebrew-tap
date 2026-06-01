cask "yolo-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.1"
  sha256 arm:   "c7cf188de78fc68b287b400d59ab487921ad4b1ec8b5c6b374c2dd4de103c84b",
         intel: "2a03fec6c76c2c71f736eb8bf58600bb0bdac67b1e4c876481a324408cea6a97"

  url "https://github.com/amanharshx/yolo-export-studio/releases/download/v#{version}/YOLO.Export.Studio_#{version}_#{arch}.dmg",
      verified: "github.com/amanharshx/yolo-export-studio/"
  name "YOLO Export Studio"
  desc "Desktop app for exporting YOLO datasets with managed runtime support"
  homepage "https://github.com/amanharshx/yolo-export-studio"

  livecheck do
    url "https://api.github.com/repos/amanharshx/yolo-export-studio/releases/latest"
    strategy :json do |json|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  depends_on :macos

  app "YOLO Export Studio.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/YOLO Export Studio.app"],
                   sudo: false
  end

  zap trash: [
    "~/.yolo-export-studio",
    "~/Library/Application Support/YOLO Export Studio",
    "~/Library/Caches/YOLO Export Studio",
    "~/Library/Preferences/com.amanharshx.yoloexportstudio.plist",
    "~/Library/Saved Application State/com.amanharshx.yoloexportstudio.savedState",
  ]

  caveats <<~EOS
    #{token} is not signed with an Apple Developer certificate.

    If you encounter a "damaged" warning, the quarantine attribute should have
    been automatically removed. If issues persist, run:
      xattr -cr "/Applications/YOLO Export Studio.app"
  EOS
end
