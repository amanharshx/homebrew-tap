cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.4"
  sha256 arm:   "cfc4dbcd47acfc5b14004bc33039ce58fdd063fab2158f5bf0cdd380e062a1f4",
         intel: "3ca20796eacddc4601b1cc63029f95c663fad690e465ab663837ae45386ab99e"

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
