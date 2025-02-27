# Laptop host configuration
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
  
  # Laptop-specific configurations
  networking.hostName = "laptop";
  
  # Enable graphical environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  
  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
  
  # Additional system packages specific to laptop
  environment.systemPackages = with pkgs; [
    # Add laptop-specific packages here
    acpi
    powertop
  ];
}
