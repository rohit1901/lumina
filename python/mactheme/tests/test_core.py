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
        """Test setting dark mode."""
        set_appearance(AppearanceMode.DARK)
        mock_run.assert_called_once()
        self.assertIn("dark mode to true", " ".join(mock_run.call_args[0][0]))

    @patch("subprocess.run")
    def test_set_light_mode(self, mock_run):
        """Test setting light mode."""
        set_appearance(AppearanceMode.LIGHT)
        mock_run.assert_called_once()
        self.assertIn("dark mode to false", " ".join(mock_run.call_args[0][0]))

    # def test_invalid_mode(self):
    #     """Test invalid mode raises ValueError."""
    #     with self.assertRaises(ValueError):
    #         set_appearance("invalid")


if __name__ == "__main__":
    unittest.main()
