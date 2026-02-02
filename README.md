# Homebrew Tap

This is a [Homebrew](https://brew.sh/) tap for installing my macOS apps.

## Installation

```bash
brew tap amanharshx/tap
brew install --cask <cask-name>
```

## Available Casks

| Cask | Description |
|------|-------------|
| `theme-toggler` | Menu bar app to toggle macOS light/dark mode |
| `yolo-ndjson-converter` | Convert Ultralytics NDJSON annotation exports to ML formats |

## Updating

```bash
brew upgrade --cask <cask-name>
```

## Uninstalling

```bash
brew uninstall --cask <cask-name>
```

## Note on Code Signing
> **Note:** These apps are not yet code-signed (Apple Developer account costs $99/year). I'm planning to get one when I can afford it.

The apps are not signed with an Apple Developer certificate. The casks automatically remove the quarantine attribute during installation. If you encounter any issues, run:

```bash
xattr -cr "/Applications/<App Name>.app"
```

## Links

### macOS Theme Toggler
- [GitHub Repository](https://github.com/amanharshx/mac-theme-toggler)

### YOLO NDJSON Converter
- [Website](https://yolondjson.zip/)
- [GitHub Repository](https://github.com/amanharshx/YOLO-Ndjson-Zip)
- [Documentation](https://yolondjson.zip/docs)
