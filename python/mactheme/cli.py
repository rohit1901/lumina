#!/usr/bin/env python3
"""theme-toggle - CLI tool for managing macOS appearance modes."""

import sys

import click

from mactheme import AppearanceMode, get_appearance, set_appearance


@click.group()
@click.version_option(version="1.0.0")
def cli():
    """theme-toggle - Manage macOS appearance modes from the command line."""
    pass


@cli.command()
def current():
    """Display the current appearance mode."""
    try:
        mode = get_appearance()
        click.echo(f"Current mode: {mode.value}")
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.argument("mode", type=click.Choice(["light", "dark"], case_sensitive=False))
def set(mode):
    """Set the appearance mode (light or dark)."""
    try:
        appearance_mode = AppearanceMode(mode.lower())
        set_appearance(appearance_mode)
        click.echo(f"Appearance mode set to: {mode}")
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)


@cli.command()
def light():
    """Switch to light mode."""
    try:
        set_appearance(AppearanceMode.LIGHT)
        click.echo("Switched to light mode")
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)


@cli.command()
def dark():
    """Switch to dark mode."""
    try:
        set_appearance(AppearanceMode.DARK)
        click.echo("Switched to dark mode")
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)


if __name__ == "__main__":
    cli()
