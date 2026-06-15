cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.3"
  sha256 arm:   "a58faadafd753d97d8024d669ea1d2a3e7fa8e9ed33d8653f063447ac95d6a1c",
         intel: "2be8ad3ed22d5ed93d16016bc3aa449c63ea781c15802ddac9e05d6ad410359c"

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
      xattr -cr "/Applications/Vision Export Studio.app"
  EOS
end
