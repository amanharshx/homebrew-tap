cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.2"
  sha256 arm:   "76d5b54acf02f0ef5970eba1bf9b7ec845a028f3e301b01d503e5732d161da85",
         intel: "af9ff1b79de5371008b9bdd4ebc69bdebabd30ceaa0a69647890e13ae14f7fa5"

  url "https://github.com/amanharshx/vision-export-studio/releases/download/v#{version}/YOLO.Export.Studio_#{version}_#{arch}.dmg",
      verified: "github.com/amanharshx/vision-export-studio/"
  name "Vision Export Studio"
  desc "Desktop app for exporting vision models with managed runtime support"
  homepage "https://github.com/amanharshx/vision-export-studio"

  livecheck do
    url "https://api.github.com/repos/amanharshx/vision-export-studio/releases/latest"
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
    "~/.vision-export-studio",
    "~/Library/Application Support/YOLO Export Studio",
    "~/Library/Application Support/Vision Export Studio",
    "~/Library/Caches/YOLO Export Studio",
    "~/Library/Caches/Vision Export Studio",
    "~/Library/Preferences/com.amanharshx.yoloexportstudio.plist",
    "~/Library/Preferences/com.amanharshx.visionexportstudio.plist",
    "~/Library/Saved Application State/com.amanharshx.yoloexportstudio.savedState",
    "~/Library/Saved Application State/com.amanharshx.visionexportstudio.savedState",
  ]

  caveats <<~EOS
    #{token} is not signed with an Apple Developer certificate.

    If you encounter a "damaged" warning, the quarantine attribute should have
    been automatically removed. If issues persist, run:
      xattr -cr "/Applications/YOLO Export Studio.app"
  EOS
end
