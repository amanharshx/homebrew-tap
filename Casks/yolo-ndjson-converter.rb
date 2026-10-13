cask "yolo-ndjson-converter" do
  arch arm: "aarch64", intel: "x64"

  version "0.3.16"
  sha256 arm:   "d604906dba43dc4faf6e1cd0324fc290db3f29c15f4aaf1c9e2d624776e48d51",
         intel: "d5d4184558fe18d57d31d7b0a92f7a72a41c26a066a6c69a04400b86895e5aba"

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
