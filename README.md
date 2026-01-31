# Homebrew Tap

This is a [Homebrew](https://brew.sh/) tap for installing [YOLO NDJSON Converter](https://yolondjson.zip/).

## Installation

```bash
brew tap amanharshx/tap
brew install --cask yolo-ndjson-converter
```

## Available Casks

| Cask | Description |
|------|-------------|
| `yolo-ndjson-converter` | Convert Ultralytics NDJSON annotation exports to ML formats |

## Updating

```bash
brew upgrade --cask yolo-ndjson-converter
```

## Uninstalling

```bash
brew uninstall --cask yolo-ndjson-converter
```

## Note on Code Signing
> **Note:** The app is not yet code-signed (Apple Developer account costs $99/year, Windows EV certificate ~$300/year). I'm planning to get these when I can afford them. 

The app is not signed with an Apple Developer certificate. The cask automatically removes the quarantine attribute during installation. If you encounter any issues, run:

```bash
xattr -cr "/Applications/YOLO NDJSON Converter.app"
```

## Links

- [YOLO NDJSON Converter Website](https://yolondjson.zip/)
- [GitHub Repository](https://github.com/amanharshx/YOLO-Ndjson-Zip)
- [Documentation](https://yolondjson.zip/docs)
