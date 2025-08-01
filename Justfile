# just is a command runner, Justfile is very similar to Makefile, but simpler.

# TODO update hostname here!
hostname := "Danielos-MacBook-Pro"

# List all the just commands
default:
  @just --list

############################################################################
#
#  Darwin related commands
#
############################################################################

[group('desktop')]
darwin:
  nix build .#darwinConfigurations.{{hostname}}.system \
    --extra-experimental-features 'nix-command flakes'

  sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}}

[group('desktop')]
darwin-debug:
  nix build .#darwinConfigurations.{{hostname}}.system --show-trace --verbose \
    --extra-experimental-features 'nix-command flakes'

  sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}} --show-trace --verbose


# Executes only home-manager to apply home related changes
# Not sure if this is a good idea. Seems to have some unexpected side effects
[group('desktop')]
home-manager:
    nix run nixpkgs#home-manager -- switch --flake . --show-trace --verbose

############################################################################
#
#  Testing related commands
#
############################################################################

# Test all configurations with dry-run builds
[group('test')]
test-all:
  @echo "Running all configuration tests..."
  @just test-darwin
  @just test-home
  @just test-structure
  @echo "\nAll configurations built successfully!"

# Test only the Darwin system configuration
[group('test')]
test-darwin:
  @echo "Testing Darwin system configuration..."
  nix build .#darwinConfigurations.{{hostname}}.system --dry-run

# Test only the home configurations
[group('test')]
test-home:
  @echo "Testing Darwin home configuration..."
  nix build .#homeConfigurations.danielo-darwin.activationPackage --dry-run
  @echo "\nTesting Linux home configuration..."
  nix build .#homeConfigurations.danielo-linux.activationPackage --dry-run

# Run flake checks to verify configuration structure
[group('test')]
test-structure:
  @echo "Checking configuration structure..."
  nix flake check
  @echo "Configuration structure check passed!"

############################################################################
#
#  nix related commands
#
############################################################################

# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}}

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs -f flake:flake-utils

# remove all generations older than 7 days
# on darwin, you may need to switch to root user to run this command
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # garbage collect all unused nix store entries(system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

[group('nix')]
fmt:
  # format the nix files in this repo
  nix fmt .

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/
