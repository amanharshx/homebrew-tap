cask "vision-export-studio" do
  arch arm: "aarch64", intel: "x64"

  version "0.1.12"
  sha256 arm:   "6f460112fb65685a6151865aade7d57396cf444f9c5134d5023e18c616af90eb",
         intel: "ebe8d762f69f969c3f169cd59e6c987ca01f0bb841c397f42e47fe0a8381bff9"

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
