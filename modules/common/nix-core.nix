# Common Nix settings for all systems
{
  pkgs,
  lib,
  username,
  system,
  ...
}: {
  nix.enable = true;

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = builtins.trace "System: ${system}" system;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix package
  nix.package = pkgs.nix;

  # Garbage collection settings
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Common Nix settings
  nix.settings = {
    # Disable auto-optimise-store because of this issue:
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = false;

    # Trusted users
    trusted-users = ["root" username];
  };
}
