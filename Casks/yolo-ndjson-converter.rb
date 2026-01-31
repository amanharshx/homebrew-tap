cask "yolo-ndjson-converter" do
  arch arm: "aarch64", intel: "x64"

  version "0.3.1"
  sha256 arm:   "74496881f3f9ca47519abdec69092afa761cad8b2f808e7c41564a7525755a7d",
         intel: "d5f7ad0d736f888c2a8504ceb625a9cc8efdf4cfa8a9bb39c4c025ca48dd3de4"

  url "https://github.com/amanharshx/YOLO-Ndjson-Zip/releases/download/v#{version}/YOLO.NDJSON.Converter_#{version}_#{arch}.dmg",
      verified: "github.com/amanharshx/YOLO-Ndjson-Zip/"

  name "YOLO NDJSON Converter"
  desc "Convert Ultralytics NDJSON annotation exports to ML formats"
  homepage "https://yolondjson.zip/"

  livecheck do
    url "https://api.github.com/repos/amanharshx/YOLO-Ndjson-Zip/releases/latest"
    strategy :json do |json|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  app "YOLO NDJSON Converter.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/YOLO NDJSON Converter.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/YOLO NDJSON Converter",
    "~/Library/Caches/YOLO NDJSON Converter",
    "~/Library/Preferences/com.yolondjson.converter.plist",
    "~/Library/Saved Application State/com.yolondjson.converter.savedState",
  ]

  caveats <<~EOS
    #{token} is not signed with an Apple Developer certificate.

    If you encounter a "damaged" warning, the quarantine attribute should have
    been automatically removed. If issues persist, run:
      xattr -cr "/Applications/YOLO NDJSON Converter.app"
  EOS
end
