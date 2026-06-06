# Homebrew Tap

This is a [Homebrew](https://brew.sh/) tap for installing my desktop apps and Linux formulas.

## macOS Cask Installation

```bash
brew tap amanharshx/tap
brew install --cask amanharshx/tap/yolo-export-studio
```

## Linux Formula Installation

```bash
brew tap amanharshx/tap
brew install amanharshx/tap/yolo-export-studio
```

## Available Formulas

| Formula | Description |
|---------|-------------|
| `yolo-export-studio` | Linux Homebrew launcher for YOLO Export Studio |

## Available Casks

| Cask | Description |
|------|-------------|
| `theme-toggler` | Menu bar app to toggle macOS light/dark mode |
| `yolo-export-studio` | Desktop app for exporting Ultralytics YOLO models with managed runtime support |
| `yolo-ndjson-converter` | Convert Ultralytics NDJSON annotation exports to ML formats |

## Updating

macOS casks:

```bash
brew upgrade --cask amanharshx/tap/yolo-export-studio
```

Linux formula:

```bash
brew upgrade amanharshx/tap/yolo-export-studio
```

## Uninstalling

macOS casks:

```bash
brew uninstall --cask amanharshx/tap/yolo-export-studio
```

Linux formula:

```bash
brew uninstall amanharshx/tap/yolo-export-studio
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

### YOLO Export Studio
- [GitHub Repository](https://github.com/amanharshx/yolo-export-studio)

### YOLO NDJSON Converter
- [Website](https://yolondjson.zip/)
- [GitHub Repository](https://github.com/amanharshx/YOLO-Ndjson-Zip)
- [Documentation](https://yolondjson.zip/docs)
