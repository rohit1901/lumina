import { app } from 'electron';
import * as path from 'path';

export const isDev = process.env.LUMINA_ENV === 'development' || !app.isPackaged;
export function debugLog(...args: any[]) {
  if (isDev) {
    console.log('[Lumina][dev]', ...args);
  }
}
export function getPythonPath(): string {
  const isDev = process.env.LUMINA_ENV === 'development' || !app.isPackaged;
  return isDev
    ? path.join(__dirname, '../../python/dist/theme-toggle')
    : path.join(process.resourcesPath, 'theme-toggle');
}
/**
 * Checks if a string value is empty, null, or undefined.
 *
 * @param value - The input string value to check. Can be a string, null, or undefined.
 * @returns True if the value is null, undefined, an empty string, or only contains whitespace; otherwise, false.
 *
 * @example
 * isEmptyOrNullish("");         // true
 * isEmptyOrNullish(null);       // true
 * isEmptyOrNullish(undefined);  // true
 * isEmptyOrNullish("   ");      // true
 * isEmptyOrNullish("hello");    // false
 */
export function isEmptyOrNullish(value: string | null | undefined): boolean {
  return value == null || value.trim() === '';
}
