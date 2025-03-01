# repo-cloner

A utility to perform a shallow clone of the danielo515/nix-darwin repository to a target directory. It uses the GitHub CLI (`gh`) for authentication and cloning, which will open a web browser if needed for authentication. On macOS systems, it also offers to build and switch to the new configuration.

The tool features a beautiful, interactive terminal UI powered by [Charm's gum](https://github.com/charmbracelet/gum) utility, providing a visually appealing experience with styled text, progress spinners, and interactive prompts.

## Features

- Beautiful, interactive terminal UI with colored text and progress indicators
- Automatic GitHub authentication using the GitHub CLI
- Shallow clone of the repository to save bandwidth and disk space
- Simple one-command operation
- On macOS: option to automatically build and switch to the cloned configuration
- Handles both new installations and existing nix-darwin setups
- Clear visual feedback throughout the process

## Usage

```bash
repo-cloner <target-directory>
```

The command takes a single argument - the target directory where the repository will be cloned.

## Example

```bash
repo-cloner ~/my-nix-config
```

The tool will guide you through the entire process with interactive prompts and visual feedback:

1. If you're not already authenticated with GitHub, it will offer to guide you through the authentication process
2. It will show a progress spinner while cloning the repository
3. On macOS systems, it will ask if you want to build and switch to the new configuration
4. If you choose to switch, it will use the cloned repository directly as your nix-darwin configuration

## Important Notes

- The tool assumes that the cloned repository (danielo515/nix-darwin) is itself a valid nix-darwin configuration
- No additional configuration files are created; the repository is used as-is
- The tool will attempt to build and switch to the configuration using the hostname of your machine

## Installation

### Using the flake directly

As the default package:
```bash
nix run github:danielo515/nix-darwin -- ~/my-config
```

Or explicitly:
```bash
nix run github:danielo515/nix-darwin#repo-cloner -- ~/my-config
```

### Adding to your configuration

Add the package to your environment packages in your Nix configuration:

```nix
environment.systemPackages = with pkgs; [
  # Other packages...
  repo-cloner
];

## Dependencies

This tool requires the following dependencies, which are automatically included as runtime dependencies:
- Git
- GitHub CLI (`gh`)
- Charm's gum utility for terminal UI
