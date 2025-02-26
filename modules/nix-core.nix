{ self, pkgs, lib, username, system, ... }: {
  nix.enable = true;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = builtins.trace "System: ${system}" system;
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;
  # This is very redundant (because it is also defined in home manager)
  # But is the only way to make it work
  # https://github.com/nix-community/home-manager/issues/6036
  users.users.${username}.home = "/Users/${username}";
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  # nix.gc = {
  #   automatic = lib.mkDefault true;
  #   options = lib.mkDefault "--delete-older-than 7d";
  # };

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings = { auto-optimise-store = false; };
  nix.extraOptions = ''
  !include /etc/nix/nix.conf.before-nix-darwin
  ''
  ;
}
