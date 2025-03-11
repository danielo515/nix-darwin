# Darwin-specific home-manager configurations
{ pkgs, ... }:
{
  imports = [
    ./programs.nix
    ./hammerspoon.nix
  ];

  # Darwin-specific configurations
  home.packages = with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
    sketchybar
  ];

  xdg.configFile.sketchybar.source = ../../dotfiles/sketchybar;

  # macOS-specific services
  services = {
    # Enable Syncthing for file synchronization
    syncthing = {
      enable = true;
    };
  };
}
