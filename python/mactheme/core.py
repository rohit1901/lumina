"""Core functionality for macOS appearance management."""

import subprocess
from enum import Enum


class AppearanceMode(Enum):
    """Enumeration of macOS appearance modes."""

    LIGHT = "light"
    DARK = "dark"
    AUTO = "auto"


def get_appearance() -> AppearanceMode:
    """
    Get the current macOS appearance mode.
    Returns:
    AppearanceMode: Current appearance mode (LIGHT, DARK, or AUTO)
    Raises:
    RuntimeError: If unable to determine appearance mode
    """
    try:
        # Check if dark mode is explicitly set
        result = subprocess.run(
            ["defaults", "read", "-g", "AppleInterfaceStyle"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0 and "Dark" in result.stdout:
            return AppearanceMode.DARK
        # Check if auto mode is enabled (Night Shift schedule)
        auto_result = subprocess.run(
            ["defaults", "read", "com.apple.CoreBrightness", "CBBlueReductionStatus"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if (
            auto_result.returncode == 0
            and "AutoBlueReductionEnabled = 1" in auto_result.stdout
        ):
            return AppearanceMode.AUTO
        # Default to light mode
        return AppearanceMode.LIGHT
    except Exception as e:
        raise RuntimeError(f"Failed to get appearance mode: {e}")


def set_appearance(mode: AppearanceMode) -> None:
    """
    Set the macOS appearance mode.
    Args:
    mode: The desired appearance mode (LIGHT, DARK, or AUTO)
    Raises:
    RuntimeError: If unable to set appearance mode
    ValueError: If mode is invalid
    """
    if not isinstance(mode, AppearanceMode):
        raise ValueError(f"Invalid mode: {mode}. Must be AppearanceMode enum.")
    try:
        if mode == AppearanceMode.DARK:
            # Enable dark mode via AppleScript
            subprocess.run(
                [
                    "osascript",
                    "-e",
                    'tell application "System Events" to tell '
                    "appearance preferences to set dark mode to true",
                ],
                check=True,
                timeout=5,
            )
        elif mode == AppearanceMode.LIGHT:
            # Enable light mode via AppleScript
            subprocess.run(
                [
                    "osascript",
                    "-e",
                    'tell application "System Events" to tell '
                    "appearance preferences to set dark mode to false",
                ],
                check=True,
                timeout=5,
            )
        elif mode == AppearanceMode.AUTO:
            # Enable auto mode via Night Shift
            subprocess.run(
                [
                    "defaults",
                    "write",
                    "com.apple.CoreBrightness",
                    "CBBlueReductionStatus",
                    "-dict",
                    "AutoBlueReductionEnabled",
                    "-bool",
                    "true",
                ],
                check=True,
                timeout=5,
            )
        print(
            "Auto mode enabled. Ensure Night Shift schedule "
            "is configured in System Preferences."
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to set appearance mode: {e}")
    except Exception as e:
        raise RuntimeError(f"Unexpected error setting appearance: {e}")
