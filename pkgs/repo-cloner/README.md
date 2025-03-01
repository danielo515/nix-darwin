# repo-cloner

A utility to perform a shallow clone of the danielo515/nix-darwin repository to a target directory. It uses the GitHub CLI (`gh`) for authentication and cloning, which will open a web browser if needed for authentication.

## Features

- Automatic GitHub authentication using the GitHub CLI
- Shallow clone of the repository to save bandwidth and disk space
- Simple one-command operation

## Usage

```bash
repo-cloner <target-directory>
```

The command takes a single argument - the target directory where the repository will be cloned.

## Example

```bash
repo-cloner ~/my-nix-config
```

If you're not already authenticated with GitHub, the tool will guide you through the authentication process before cloning the repository.

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

This tool requires the GitHub CLI (`gh`) and Git to be installed, which are automatically included as runtime dependencies.
