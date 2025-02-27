# Hammerspoon configuration
{ config, lib, pkgs, ... }:

{
  # Link the hammerspoon configuration from the dotfiles directory
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon".source =
      config.lib.file.mkOutOfStoreSymlink /etc/nix-darwin/dotfiles/hammerspoon;
  };
  
  # Alternative using xdg.configFile if you prefer
  # xdg.configFile."hammerspoon".source =
  #   config.lib.file.mkOutOfStoreSymlink /etc/nix-darwin/dotfiles/hammerspoon;
}
