cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.13"
  sha256 arm:   "9d8d30d9feb7030e239279215357d82fc9066a8fa8d1205de8b1b2947a92bc16",
         intel: "8030cd4cbbfd552b76b0b028cb7606fc9a94b24a955f43ff6ca63bd0edb3a00f"

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
