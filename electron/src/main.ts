import { app, BrowserWindow, Tray, Menu, nativeImage, Notification } from 'electron';
import * as path from 'path';
import { spawn } from 'child_process';

interface AppearanceMode {
  mode: 'light' | 'dark';
  label: string;
  icon: string;
}

class LuminaApp {
  private tray: Tray | null = null;
  private window: BrowserWindow | null = null;
  private pythonPath: string;
  private currentMode: 'light' | 'dark' = 'light';
  private pollInterval: NodeJS.Timeout | null = null;

  constructor() {
    // Path to bundled Python executable
    const resourcesPath = app.isPackaged
      ? path.join(process.resourcesPath, 'theme-toggle')
      : path.join(__dirname, '../../python/dist/theme-toggle');
    this.pythonPath = resourcesPath;
  }

  public async initialize(): Promise<void> {
    // Ensure single instance
    const gotTheLock = app.requestSingleInstanceLock();
    if (!gotTheLock) {
      app.quit();
      return;
    }
    await app.whenReady();

    // Check if running on macOS
    if (process.platform !== 'darwin') {
      const notification = new Notification({
        title: 'Platform Not Supported',
        body: 'Lumina only works on macOS 10.14 (Mojave) or later.',
      });
      notification.show();
      app.quit();
      return;
    }

    // Main initialization
    this.createTray();
    //this.createWindow();
    await this.updateCurrentMode();
    this.startPolling();
  }

  private createTray(): void {
    const iconPath = path.join(__dirname, '../assets/IconTemplate.png');
    const icon = nativeImage.createFromPath(iconPath);
    icon.setTemplateImage(true);

    this.tray = new Tray(icon);
    this.tray.setToolTip(`Lumina: ${this.currentMode}`);

    this.tray.on('right-click', () => {
      this.showTrayMenu();
    });

    this.updateTrayMenu();
  }

  private updateTrayMenu(): void {
    if (!this.tray) return;
    const contextMenu = Menu.buildFromTemplate([
      {
        label: 'Light Mode',
        type: 'radio',
        checked: this.currentMode === 'light',
        icon: this.getIconPath('sun'),
        click: () => this.setMode('light'),
      },
      {
        label: 'Dark Mode',
        type: 'radio',
        checked: this.currentMode === 'dark',
        icon: this.getIconPath('moon'),
        click: () => this.setMode('dark'),
      },
      { type: 'separator' },
      {
        label: `Current: ${this.currentMode.charAt(0).toUpperCase() + this.currentMode.slice(1)}`,
        icon: this.getIconPath('info'),
        enabled: false,
      },
      { type: 'separator' },
      // {
      //   label: "Show Window",
      //   click: () => this.showWindow(),
      // },
      {
        label: 'Quit Lumina',
        accelerator: 'Command+Q',
        click: () => {
          app.quit();
        },
      },
    ]);
    this.tray.setContextMenu(contextMenu);
  }

  private showTrayMenu(): void {
    this.updateTrayMenu();
    if (this.tray) {
      this.tray.popUpContextMenu();
    }
  }

  private getIconPath(name: string): string {
    return path.join(__dirname, `../assets/${name}.png`);
  }

  private async setMode(mode: AppearanceMode['mode']): Promise<void> {
    try {
      await this.executePythonCommand(['set', mode]);
      this.currentMode = mode;
      this.updateTrayMenu();
      if (this.tray) {
        this.tray.setToolTip(`Lumina: ${mode}`);
      }
      // Show notification
      const notification = new Notification({
        title: 'Lumina',
        body: `Switched to ${mode.charAt(0).toUpperCase() + mode.slice(1)} mode`,
        silent: true,
      });
      notification.show();
      // Update window if visible
      if (this.window && this.window.isVisible()) {
        this.window.webContents.send('mode-update', mode);
      }
    } catch (error) {
      const notification = new Notification({
        title: 'Lumina Error',
        body: `Failed to switch mode: ${error}`,
      });
      notification.show();
    }
  }

  private async updateCurrentMode(): Promise<void> {
    try {
      const mode = await this.executePythonCommand(['current']);
      const modeText = mode.replace('Current mode: ', '').trim();
      if (modeText === 'light' || modeText === 'dark') {
        this.currentMode = modeText;
        this.updateTrayMenu();
        if (this.tray) {
          this.tray.setToolTip(`Lumina: ${this.currentMode}`);
        }
      }
    } catch (error) {
      console.error('Failed to update current mode:', error);
    }
  }

  private executePythonCommand(args: string[]): Promise<string> {
    return new Promise((resolve, reject) => {
      const process = spawn(this.pythonPath, args);
      let output = '';
      let errorOutput = '';
      process.stdout.on('data', data => {
        output += data.toString();
      });
      process.stderr.on('data', data => {
        errorOutput += data.toString();
      });
      process.on('close', code => {
        if (code === 0) {
          resolve(output.trim());
        } else {
          reject(new Error(errorOutput || `Process exited with code ${code}`));
        }
      });
      process.on('error', error => {
        reject(error);
      });
    });
  }

  private startPolling(): void {
    // Poll every 10 seconds to sync with system changes
    this.pollInterval = setInterval(() => {
      this.updateCurrentMode();
    }, 10000);
  }

  public cleanup(): void {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
    }
  }
}

// Application entry point
const luminaApp = new LuminaApp();
luminaApp.initialize().catch(error => {
  console.error('Failed to initialize Lumina:', error);
  app.quit();
});
app.on('will-quit', () => {
  luminaApp.cleanup();
});
