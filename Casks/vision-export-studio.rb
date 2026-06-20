cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.6"
  sha256 arm:   "7e1b858b0466197461b8d913f5422b50af2e3b989b20a7f6b11a36d5219ffced",
         intel: "4dc40d71272048e7c25b749541c162c27cbf2649f5f8fc8029b808a3771e82fe"

  url "https://github.com/amanharshx/vision-export-studio/releases/download/v#{version}/Vision.Export.Studio_#{version}_#{arch}.dmg"
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

  app "Vision Export Studio.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Vision Export Studio.app"],
                   sudo: false
  end

  zap trash: [
    "~/.vision-export-studio",
    "~/.yolo-export-studio",
    "~/Library/Application Support/Vision Export Studio",
    "~/Library/Application Support/YOLO Export Studio",
    "~/Library/Caches/Vision Export Studio",
    "~/Library/Caches/YOLO Export Studio",
    "~/Library/Preferences/com.amanharshx.visionexportstudio.plist",
    "~/Library/Preferences/com.amanharshx.yoloexportstudio.plist",
    "~/Library/Saved Application State/com.amanharshx.visionexportstudio.savedState",
    "~/Library/Saved Application State/com.amanharshx.yoloexportstudio.savedState",
  ]

  caveats <<~EOS
    #{token} is not signed with an Apple Developer certificate.

    If you encounter a "damaged" warning, the quarantine attribute should have
    been automatically removed. If issues persist, run:
      xattr -cr "/Applications/Vision Export Studio.app"
  EOS
end
