# amanharshx's Homebrew Tap

Homebrew tap for my macOS casks and Linux formulas.

## Install

```bash
brew tap amanharshx/tap
```

Install a cask:

```bash
brew install --cask amanharshx/tap/<cask>
```

Install a formula:

```bash
brew install amanharshx/tap/<formula>
```

## Packages

### Casks

- `theme-toggler` — Menu bar app to toggle macOS light/dark mode
- `vision-export-studio` — Desktop app package for Vision Export Studio
- `yolo-ndjson-converter` — Convert Ultralytics NDJSON annotation exports to ML formats

### Formulae

- `vision-export-studio` — Linux Homebrew launcher for Vision Export Studio

## Update / Uninstall

```bash
brew update
brew upgrade
brew upgrade --cask amanharshx/tap/<cask>
brew upgrade amanharshx/tap/<formula>
brew uninstall --cask amanharshx/tap/<cask>
brew uninstall amanharshx/tap/<formula>
```

Use `brew uninstall --cask --zap <token>` for casks when you also want Homebrew to remove app data.

## Notes

- These casks are not signed with an Apple Developer certificate. Quarantine is removed during installation.
- Run `brew info amanharshx/tap/<token>` for package-specific caveats.

## Links

- [Theme Toggler](https://github.com/amanharshx/mac-theme-toggler)
- [Vision Export Studio](https://github.com/amanharshx/vision-export-studio)
- [YOLO NDJSON Converter](https://github.com/amanharshx/YOLO-Ndjson-Zip)
- [YOLO NDJSON Converter Docs](https://yolondjson.zip/docs)
