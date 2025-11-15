# Lumina

A modern, native macOS utility for toggling system appearance modes (Light, Dark, Auto) from both a beautiful menu bar app (Electron) and a powerful CLI/library (Python).

---

## 🌟 Features

- **Instant theme toggle:** Switch Light/Dark/Auto from your menu bar
- **Native macOS look:** Inspired by Apple Human Interface Guidelines
- **Fast CLI tool (`theme-toggle`):** Automate mode changes from the terminal
- **Modern architecture:** TypeScript + Electron frontend, Python 3 backend (via Poetry)
- **Notarization and code signing ready:** For direct or App Store distribution
- **Fully unit and integration tested**
- **Accessible & ergonomic UI**

---

## 📦 Install & Set Up

### 1. **Clone the repo**
```
git clone https://github.com/rohit1901/lumina.git
cd lumina
```

---

### 2. **Set up the Python CLI (Poetry)**

> Used by Electron as a backend, and directly by CLI users.

```
cd python
pipx install poetry              # Or: pip install --user poetry
poetry install                   # Creates/activates virtualenv, installs deps
```

- **Test the CLI**:
    ```
    poetry run theme-toggle current    # Query current appearance mode
    poetry run theme-toggle dark       # Switch to dark mode
    poetry run theme-toggle light      # Switch to light mode
    poetry run theme-toggle auto       # Switch to auto mode
    poetry run theme-toggle --help     # Show help
    ```

- **Run unit tests**:
    ```
    poetry run python -m unittest discover
    ```

- **(Optional) Build a standalone binary**:
    ```
    poetry run pyinstaller --clean mactheme/theme-toggle.spec
    # Results in ./dist/theme-toggle
    ```

---

### 3. **Set up and build Electron (TypeScript app)**

> Integrates with Python CLI for macOS theme control.

```
cd electron
npm install                       # Installs Electron, TypeScript, etc.
npm run build                     # Compiles TypeScript
npm run dev                       # Runs Electron app in development mode
```

#### **Menu bar app use:**
- The icon appears in the macOS menu bar.
- Left-click: Opens compact popover UI for theme selection
- Right-click: Opens context menu ("Light", "Dark", "Auto", "Current Mode", "Quit")
- Tray tooltip shows current mode, live-updating (polled via CLI)

#### **Unit and integration tests:**
```
npm test                          # Runs Jest-powered Electron tests
```

#### **Package for distribution:**
```
npm run package:mac               # Creates Mac DMG installer (codesign if configured)
```

---

### 4. **Full cross-platform packaging**

- **The Electron app spawns the standalone Python CLI as a subprocess.**
- The Python CLI must exist at `python/dist/theme-toggle` for bundling and runtime.
- Both parts are packaged together via Electron Builder (see `electron/package.json`).

---

## 📚 Project Structure

```
lumina/
├── python/
│   ├── mactheme/
│   │   ├── __init__.py
│   │   ├── core.py
│   │   ├── cli.py
│   │   └── tests/
│   │       └── test_core.py
│   ├── pyproject.toml
│   └── theme-toggle.spec
├── electron/
│   ├── src/
│   │   ├── main.ts
│   │   └── __tests__/
│   │       └── integration.test.ts
│   ├── renderer/
│   │   ├── index.html
│   │   └── styles.css
│   ├── assets/
│   │   └── README.md
│   ├── build/
│   │   ├── entitlements.mac.plist
│   │   └── entitlements.mac.inherit.plist
│   ├── package.json
│   ├── tsconfig.json
│   ├── jest.config.js
│   └── .gitignore
├── build.sh
├── package.sh
└── README.md
```

---

## 🧩 How It Works

- **Electron app** shows the menu bar icon and UI, communicates with users.
- **Electron main process** calls Python CLI (`theme-toggle`) via Node.js `child_process` to read/set system appearance.
- **Python CLI** changes macOS appearance using system calls (`osascript`, `defaults`), updating instantly.
- **UI and tray tooltip** update automatically via periodic polling.

---

## 🤖 Developer Workflow

- Change Python backend logic: test in `python/mactheme/core.py` and CLI in `python/mactheme/cli.py`
- Change Electron UI/logic: alter files in `electron/src/` and `electron/renderer/`
- Test backend in isolation with `poetry run python -m unittest discover`
- Test frontend and integration with `npm test` (Jest)
- Build binary for Electron release with `poetry run pyinstaller ...` and bundle for Mac DMG with `npm run package:mac`

---

## 🧪 Testing

- **Python unit tests:**
  ```
  poetry run python -m unittest discover
  ```
- **Electron/Jest tests:**
  ```
  npm test
  ```
- **Integration tests simulate end-to-end flows** (see `electron/src/__tests__/integration.test.ts`).

---

## 🔏 Packaging & Distribution

- **Mac DMG Installer:** `electron/dist/Lumina-<version>.dmg`
- **Code signing and entitlements:** See `electron/build/` and `package.json`
- **Notarization ready:** Use `apple-id`, `team-id` for Mac App Store submission
- **Standalone Python CLI:** Symlink system-wide if desired:
  ```
  sudo ln -s $(pwd)/python/dist/theme-toggle /usr/local/bin/theme-toggle
  ```

---

## ⚡ Troubleshooting

- **Python CLI not found:** Rebuild with `poetry run pyinstaller --clean ...`, verify output in `dist/`.
- **Import errors:** Check for relative vs absolute imports (`from .core import ...`).
- **PyInstaller errors:** Ensure Python version `<3.15`. Use `poetry env use python3.14` if needed.
- **Electron build fails:** Ensure Node.js v18+ and Python CLI present for subprocess communication.
- **Code signing fails:** Check entitlements files, proper developer certificates, and correct DMG output folder.

---

## 🛡️ Security & Privacy

- **No data collection, no analytics.**
- **All operations are local to your device.**
- **Built for Mac App Store compliance.**

---

## 📑 License

MIT License

---

## 🙏 Credits

Developed by Lumina Dev
- Python: Poetry, Click, PyInstaller
- Electron: TypeScript, Electron, Jest
- macOS: AppleScript

---

## 💡 Tips & Advanced Usage

- To add more appearance features, extend `mactheme/core.py` and the CLI.
- Use the Python CLI in scripts and automation workflows.
- Electron app can be extended with custom UI features or menu options.
- Integrate with macOS Shortcuts for automation!
