"""Unit tests for mactheme core functionality."""

import subprocess
import unittest
from unittest.mock import MagicMock, patch

from mactheme.core import AppearanceMode, get_appearance, set_appearance


class TestAppearanceMode(unittest.TestCase):
    """Tests for appearance mode detection and setting."""

    @patch("subprocess.run")
    def test_get_dark_mode(self, mock_run):
        """Test detection of dark mode."""
        mock_run.return_value = MagicMock(returncode=0, stdout="Dark")
        self.assertEqual(get_appearance(), AppearanceMode.DARK)

    @patch("subprocess.run")
    def test_get_light_mode(self, mock_run):
        """Test detection of light mode."""
        mock_run.return_value = MagicMock(returncode=1, stdout="")
        self.assertEqual(get_appearance(), AppearanceMode.LIGHT)

    @patch("subprocess.run")
    def test_set_dark_mode(self, mock_run):
        set_appearance(AppearanceMode.DARK)
        assert mock_run.call_count == 1
        mock_run.assert_any_call(
            [
                "osascript",
                "-e",
                'tell application "System Events" to tell appearance preferences to set dark mode to true',
            ],
            check=True,
            timeout=5,
        )

    @patch("subprocess.run")
    def test_set_light_mode(self, mock_run):
        set_appearance(AppearanceMode.LIGHT)
        assert mock_run.call_count == 1
        mock_run.assert_any_call(
            [
                "osascript",
                "-e",
                'tell application "System Events" to tell appearance preferences to set dark mode to false',
            ],
            check=True,
            timeout=5,
        )


if __name__ == "__main__":
    unittest.main()
