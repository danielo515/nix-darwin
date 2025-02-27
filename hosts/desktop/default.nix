# Desktop host configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    # Import common configuration
    ../common
    
    # Import hardware configuration
    ./hardware-configuration.nix
    
    # Import NixOS-specific modules
    ../../modules/nixos
  ];
  
  # Desktop-specific configurations
  networking.hostName = "desktop";
  
  # Enable graphical environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  
  # Additional system packages specific to desktop
  environment.systemPackages = with pkgs; [
    # Add desktop-specific packages here
  ];
}
