# Darwin-specific home-manager configurations
{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./hammerspoon.nix
    ../../modules/simple-bar.nix
    ./bin.nix
    ./aerospace.nix
  ];

  # Darwin-specific configurations
  home.packages = with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
    sketchybar
    jankyborders
  ];

  xdg.configFile.sketchybar.source = ../../dotfiles/sketchybar;

}
