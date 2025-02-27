# Linux-specific home-manager configurations
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Linux-specific home configuration
  home.packages = with pkgs; [
    # Linux-specific packages
    xclip
    # gnome.gnome-tweaks
  ];

  # Linux-specific services
  services = {
    # Enable gpg-agent for SSH authentication
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
    };
  };
}
