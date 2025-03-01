# repo-cloner

A simple utility to perform a shallow clone of the danielo515/nix-darwin repository to a target directory.

## Usage

```bash
repo-cloner <target-directory>
```

The command takes a single argument - the target directory where the repository will be cloned.

## Example

```bash
repo-cloner ~/my-nix-config
```

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
