# Common Nix settings for all systems
{ self, pkgs, lib, username, system, isDarwin, ... }:

{
  nix.enable = true;

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = builtins.trace "System: ${system}" system;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for version
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # User home directory (platform-specific)
  users.users.${username}.home =
    if isDarwin then "/Users/${username}" else "/home/${username}";

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
    trusted-users = [ "root" username ];
  };

  # Darwin-specific settings
  nix.extraOptions = lib.mkIf isDarwin ''
    !include /etc/nix/nix.conf.before-nix-darwin
  '';

  # Darwin state version
  system.stateVersion = lib.mkIf isDarwin 6;
}
