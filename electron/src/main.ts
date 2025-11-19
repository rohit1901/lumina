import { app, Tray, Menu, nativeImage, Notification } from 'electron';
import * as path from 'path';
import { spawn } from 'child_process';
import { debugLog, isDev, isEmptyOrNullish } from './util';

type AppearanceMode = 'light' | 'dark';

class LuminaApp {
  private tray: Tray | null = null;
  private pollInterval: NodeJS.Timeout | null = null;
  private isBusy = false;
  private currentMode: AppearanceMode = 'light';

  constructor() {
    if (isDev) debugLog('[Lumina] Running in development mode');
  }

  public async initialize(): Promise<void> {
    // Ensure only one instance
    if (!app.requestSingleInstanceLock()) {
      if (isDev) debugLog('Another instance detected, quitting');
      app.quit();
      return;
    }
    await app.whenReady();

    // Only run on macOS
    if (process.platform !== 'darwin') {
      if (isDev) debugLog('Not macOS, quitting');
      new Notification({
        title: 'Platform Not Supported',
        body: 'Lumina runs only on macOS 10.14+.',
      }).show();
      app.quit();
      return;
    }

    this.createTray();
    await this.updateCurrentMode();
    this.startPolling();
  }

  private createTray(): void {
    const icon = nativeImage.createFromPath(path.join(__dirname, '../assets/IconTemplate.png'));
    icon.setTemplateImage(true);

    this.tray = new Tray(icon);
    this.tray.setToolTip(`Lumina: ${this.currentMode}`);

    this.tray.on('right-click', () => {
      if (!this.isBusy) this.showTrayMenu();
    });
    this.tray.on('click', () => {
      if (!this.isBusy) this.showTrayMenu();
    });

    this.updateTrayMenu();
  }

  private setTrayIconBusy(busy: boolean) {
    if (!this.tray) return;
    const iconName = busy ? 'IconTemplate-disabled.png' : 'IconTemplate.png';
    const iconPath = path.join(__dirname, '../assets', iconName);
    const icon = nativeImage.createFromPath(iconPath);
    icon.setTemplateImage(true);
    this.tray.setImage(icon);
    this.tray.setToolTip(busy ? 'Lumina: Switching theme...' : `Lumina: ${this.currentMode}`);
  }

  private getIconPath(name: string): string {
    return path.join(__dirname, `../assets/${name}.png`);
  }

  private updateTrayMenu(): void {
    if (!this.tray) return;

    const switching = this.isBusy ? ' (switching...)' : '';
    const menu = Menu.buildFromTemplate([
      {
        label: 'Light Mode' + switching,
        type: 'radio',
        checked: this.currentMode === 'light',
        icon: this.getIconPath('sun'),
        click: () => void this.setMode('light'),
        enabled: !this.isBusy,
      },
      {
        label: 'Dark Mode' + switching,
        type: 'radio',
        checked: this.currentMode === 'dark',
        icon: this.getIconPath('moon'),
        click: () => void this.setMode('dark'),
        enabled: !this.isBusy,
      },
      { type: 'separator' },
      {
        label: `Current: ${this.currentMode[0].toUpperCase() + this.currentMode.slice(1)}`,
        icon: this.getIconPath('info'),
        enabled: false,
      },
      { type: 'separator' },
      {
        label: 'Quit Lumina',
        accelerator: 'Command+Q',
        click: () => app.quit(),
      },
    ]);
    this.tray.setContextMenu(menu);
  }

  private showTrayMenu(): void {
    this.updateTrayMenu();
    this.tray?.popUpContextMenu();
  }

  // Directly run osascript/defaults system commands, no Python!
  private executeSystemCommand(command: string, args: string[]): Promise<string> {
    if (isDev) debugLog('System command:', command, args);
    return new Promise((resolve, reject) => {
      const process = spawn(command, args);
      let out = '',
        err = '';
      process.stdout.on('data', data => (out += data.toString()));
      process.stderr.on('data', data => (err += data.toString()));

      process.on('close', code => {
        if (isDev)
          debugLog(
            `Exited ${command} with code:`,
            code,
            'stdout:',
            out,
            'stderr:',
            isEmptyOrNullish(err) ? 'N/A' : err,
          );
        if (code === 0) resolve(out.trim());
        else reject(new Error(err.trim() || `Process exited with code ${code}`));
      });
      process.on('error', reject);
    });
  }

  private async setMode(mode: AppearanceMode): Promise<void> {
    if (this.isBusy) return;
    this.isBusy = true;
    this.setTrayIconBusy(true);
    this.updateTrayMenu();

    const script =
      mode === 'dark'
        ? 'tell application "System Events" to tell appearance preferences to set dark mode to true'
        : 'tell application "System Events" to tell appearance preferences to set dark mode to false';

    try {
      await this.executeSystemCommand('osascript', ['-e', script]);
      this.currentMode = mode;
      if (this.tray) this.tray.setToolTip(`Lumina: ${mode}`);
      new Notification({
        title: 'Lumina',
        body: `Switched to ${mode[0].toUpperCase() + mode.slice(1)} mode`,
        silent: true,
      }).show();
    } catch (error: any) {
      new Notification({
        title: 'Lumina Error',
        body: `Failed to switch appearance: ${error.message || error}`,
      }).show();
    } finally {
      this.isBusy = false;
      this.setTrayIconBusy(false);
      this.updateTrayMenu();
    }
  }

  private async updateCurrentMode(): Promise<void> {
    try {
      const result = await this.executeSystemCommand('defaults', [
        'read',
        '-g',
        'AppleInterfaceStyle',
      ]);
      // If AppleInterfaceStyle returns "Dark", set dark, otherwise light.
      const isDark = result.trim().toLowerCase() === 'dark';
      this.currentMode = isDark ? 'dark' : 'light';
      this.updateTrayMenu();
      this.tray?.setToolTip(`Lumina: ${this.currentMode}`);
    } catch (_error) {
      // Treat missing AppleInterfaceStyle as "light" mode
      this.currentMode = 'light';
      this.updateTrayMenu();
      this.tray?.setToolTip(`Lumina: ${this.currentMode}`);
      // No error notification for polling failure, keeps polling!
    }
  }

  private startPolling(): void {
    if (this.pollInterval) clearInterval(this.pollInterval);
    this.pollInterval = setInterval(() => this.updateCurrentMode(), 10000);
  }

  public cleanup(): void {
    if (this.pollInterval) clearInterval(this.pollInterval);
  }
}

// --- Entry Point ---
const luminaApp = new LuminaApp();
luminaApp.initialize().catch(error => {
  if (isDev) debugLog('Lumina failed to initialize:', error);
  app.quit();
});
app.on('will-quit', () => {
  luminaApp.cleanup();
});
