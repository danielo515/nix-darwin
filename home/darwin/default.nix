# Darwin-specific home-manager configurations
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./programs.nix
  ];

  # Darwin-specific configurations
  home.packages = with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
  ];

  # macOS-specific services
  services = {
    # Enable Syncthing for file synchronization
    syncthing = {
      enable = true;
    };

    # Enable Karabiner Elements for keyboard customization
    # karabiner-elements.enable = true;
  };
}
