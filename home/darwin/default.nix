# Darwin-specific home-manager configurations
{ pkgs, ... }: {
  imports = [ ./programs.nix ./hammerspoon.nix ];

  # Darwin-specific configurations
  home.packages = with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
  ];

  # macOS-specific services
  services = {
    # Enable Syncthing for file synchronization
    syncthing = { enable = true; };
  };
}
