cask "yolo-ndjson-converter" do
  arch arm: "aarch64", intel: "x64"

  version "0.4.0"
  sha256 arm:   "ef297941f10572acfd521b1c260fb43c60792c2a89abc2d9bba6d613819ed7c6",
         intel: "107b2ae285b8c86eacb9361e0b3a6b3411c5efc02f6d03203e9dbfd3453a69f2"

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
