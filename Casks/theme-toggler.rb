cask "theme-toggler" do
  version "1.0.0"
  sha256 "d8bcdad408e74d06f6a199dd7b9f1704cce85288c9074a8979edee012574ae64"

  url "https://github.com/amanharshx/mac-theme-toggler/releases/download/v#{version}/ThemeToggler.zip"
  name "macOS Theme Toggler"
  desc "Menu bar app to toggle macOS light/dark mode"
  homepage "https://github.com/amanharshx/mac-theme-toggler"

  app "Theme Toggler.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-d", "com.apple.quarantine", "#{appdir}/Theme Toggler.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.aman.theme-toggler.plist",
  ]
end