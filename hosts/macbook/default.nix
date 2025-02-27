# Configuration for macbook host
{ lib, pkgs, username, hostname, system, ... }:

{
  imports = [
    # Import common host configuration
    ../common
    
    # Import darwin-specific modules
    ../../modules/darwin
    
    # Import darwin-specific configuration
    ./darwin-configuration.nix
  ];
  
  # Host-specific system configurations
  networking.hostName = hostname;
  networking.computerName = "Danielo's MacBook Pro";
  
  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit username hostname system; };
    users.${username} = import ../../home;
    backupFileExtension = "bk";
  };
  
  # Host-specific system preferences
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
    };
  };
  
  # Host-specific keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
  
  # State version for nix-darwin
  system.stateVersion = 6;
}
