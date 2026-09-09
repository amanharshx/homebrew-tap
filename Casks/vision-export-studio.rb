cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.14"
  sha256 arm:   "3e75d5a63944b6344bf88957ef59326815dcdf9ea4ee2a4d1e212e7a5b6433a8",
         intel: "35044457863b0cf8ddbd501a6a75ec3424bfe7f08fdb48a3f93bc0f635867aca"

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
