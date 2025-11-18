# Lumina Quickstart

This guide helps you build, test, and run the Lumina macOS theme switcher: an Electron-based menu bar app with a Python CLI backend managed by Poetry.

---

## 🚀 Prerequisites

- **macOS** 10.14+ (Mojave or newer)
- **Node.js** v18+ and npm
- **Python** 3.8 up to <3.15 ([Pyenv](https://github.com/pyenv/pyenv) recommended for version management)
- **Poetry**
    ```
    pipx install poetry  # Or: pip install --user poetry
    ```
- **Xcode Command Line Tools** (for notarization, packaging)

---

## 📦 Clone & Set Up

```
git clone https://github.com/rohit1901/lumina.git
cd lumina
```

---

## 🐍 Python (CLI & Library)

### Install dependencies and set up virtual environment:
```
cd python
poetry install
```

### Run CLI commands:
```
poetry run theme-toggle current    # Show current system appearance mode
poetry run theme-toggle dark       # Switch to dark mode
poetry run theme-toggle light      # Switch to light mode
poetry run theme-toggle auto       # Switch to auto (Night Shift) mode
```

### Run unit tests:
```
pytest
```
All tests should pass with `OK`.

### (Optional) Build CLI as a standalone binary:
```
./build.sh --python-only
```
Symlink for system-wide use:
```
sudo ln -s $(pwd)/dist/theme-toggle /usr/local/bin/theme-toggle
```
Then use:
```
theme-toggle light
```

---

## ⚡ Electron (macOS Menu Bar App)

### Install and build:
```
cd electron
npm install
npm run build          # Compile TypeScript app
npm run dev            # Start app in development mode
```

### Run tests:
```
npm test               # Jest unit/integration tests
```

### Package for distribution (DMG installer):
```
npm run package:mac
# Or use the CLI: ./package.sh --mac-only
```
Find `.dmg` installer in `electron/out/`.

---

## 🖱️ Using Lumina

- Launch the Electron app: tray icon appears in your menu bar.
- Left-click: Popover UI for mode switching.
- Right-click: Quick menu for Light/Dark/Auto/Current/Quit.
- Tray tooltip live-updates mode.

The Electron app works by spawning the Python CLI to set/query system appearance.

---

## 📚 Project Layout

```
lumina/
├── python/
│   ├── mactheme/
│   │   ├── __init__.py
│   │   ├── core.py
│   │   ├── cli.py
│   │   └── tests/
│   ├── pyproject.toml
│   └── theme-toggle.spec
├── electron/
│   ├── src/
│   │   ├── main.ts
│   │   └── __tests__/main.test.ts
│   ├── renderer/
│   │   ├── index.html
│   │   └── styles.css
│   ├── assets/
│   ├── build/
│   ├── package.json
│   └── tsconfig.json
├── build.sh
├── package.sh
└── Quickstart.md
```

---

## 🧪 Testing Everything

- **Python unit tests:**
    ```
    pytest
    ```
- **JS/Electron tests:**
    ```
    npm test
    ```
- **End-to-end tray/CLI integration:** Launch the app and check theme changes via menu and CLI.

---

## 🔏 Troubleshooting

- **Python errors:** Make sure you’re using Python `<3.15`. Run `poetry env use python3.14` if needed.
- **Module errors (CLI):** Ensure `[tool.poetry.scripts]` points to `mactheme.cli:cli` and `cli.py` is inside the package.
- **Electron fails to find Python CLI:** Ensure the PyInstaller binary exists at `python/dist/theme-toggle`.
- **Code signing/packaging:** Follow Apple Developer docs for provisioning profiles and entitlements.

---

## 💡 Advanced

- Edit the app’s appearance logic in `python/mactheme/core.py`.
- Change or add menu options in `electron/src/main.ts`.
- Change UI design in `electron/renderer/index.html` and `styles.css`.
- Package for Mac App Store: see Electron Builder & Apple docs for info.

---

## ❓ Help

- **CLI help:** `poetry run theme-toggle --help`
- **Electron docs:** [Electron](https://www.electronjs.org/)
- **Poetry docs:** [Poetry](https://python-poetry.org/docs/)
- **Mac Scripting:** [AppleScript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html)

---

## 📑 License

MIT License
