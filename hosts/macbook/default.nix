# Configuration for macbook host
{
  lib,
  pkgs,
  username,
  hostname,
  system,
  ...
}: {
  imports = [
    # Import common modules
    ../../modules/common

    # Import darwin-specific modules
    ../../modules/darwin

    # Import darwin-specific configuration
    ./darwin-configuration.nix
  ];

  # Common system packages (previously in hosts/common)
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # Host-specific system configurations
  networking.hostName = hostname;
  networking.computerName = "Danielo's MacBook Pro";

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit username hostname system;};
    users.${username} = import ../../home;
    backupFileExtension = lib.mkForce "home-bk";
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
