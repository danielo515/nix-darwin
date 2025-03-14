# User Bin Directory

This directory contains user scripts and binaries that are automatically linked to `~/.bin` in your home directory and added to your PATH.

## Guidelines

1. All files in this directory must be tracked in version control
2. Executable scripts should have proper permissions (`chmod +x`)
3. Include a brief comment at the top of each script explaining its purpose
4. Use shebang lines to specify the interpreter (e.g., `#!/bin/sh`, `#!/usr/bin/env python3`)
5. Keep scripts organized and well-documented

## Usage

Files placed in this directory will be:
1. Symlinked to `~/.bin` in your home directory
2. Added to your PATH environment variable
3. Available as commands from any terminal

Remember to commit any changes to this directory to ensure they're properly tracked in version control.
