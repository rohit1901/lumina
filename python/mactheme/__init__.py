"""mactheme - A Python library for managing macOS appearance modes."""

__version__ = "1.0.0"
from .core import AppearanceMode, get_appearance, set_appearance

__all__ = ["get_appearance", "set_appearance", "AppearanceMode"]
