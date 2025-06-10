"""A simple calculator module for demonstration."""

from .calculator import Calculator

# __version__ = "1"
# this is not part of workflow as version number is hard coded in pyproject.toml and not passed from here. Version number in pytproject.toml is used for the workflow and must be the latest version.

__all__ = ["Calculator"]
