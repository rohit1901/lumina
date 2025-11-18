"""Core functionality for macOS appearance management."""

import subprocess
from enum import Enum


class AppearanceMode(Enum):
    """Enumeration of macOS appearance modes."""

    LIGHT = "light"
    DARK = "dark"


def get_appearance() -> AppearanceMode:
    """
    Get the current macOS appearance mode.
    Returns:
        AppearanceMode: Current appearance mode (LIGHT or DARK)
    Raises:
        RuntimeError: If unable to determine appearance mode
    """
    try:
        dark_result = subprocess.run(
            ["defaults", "read", "-g", "AppleInterfaceStyle"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if dark_result.returncode == 0 and "Dark" in dark_result.stdout:
            return AppearanceMode.DARK
        return AppearanceMode.LIGHT
    except Exception as e:
        raise RuntimeError(f"Failed to get appearance mode: {e}")


def set_appearance(mode: AppearanceMode) -> None:
    if not isinstance(mode, AppearanceMode):
        raise ValueError(f"Invalid mode: {mode}. Must be AppearanceMode enum.")
    try:
        if mode == AppearanceMode.DARK:
            subprocess.run(
                [
                    "osascript",
                    "-e",
                    'tell application "System Events" to tell appearance preferences to set dark mode to true',
                ],
                check=True,
                timeout=5,
            )
        elif mode == AppearanceMode.LIGHT:
            subprocess.run(
                [
                    "osascript",
                    "-e",
                    'tell application "System Events" to tell appearance preferences to set dark mode to false',
                ],
                check=True,
                timeout=5,
            )
        else:
            raise ValueError(f"Unknown appearance mode: {mode}")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to set appearance mode: {e}")
    except Exception as e:
        raise RuntimeError(f"Unexpected error setting appearance: {e}")
