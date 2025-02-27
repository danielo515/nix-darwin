# Common configuration for all hosts
{ lib, pkgs, ... }:

{
  # Common configuration that applies to all hosts
  
  # Import common modules
  imports = [
    ../../modules/common
  ];
  
  # Common system packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
  
  # Common system settings
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
}
