# Darwin-specific configuration for macbook
{ config, lib, pkgs, username, ... }:

{
  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # User configuration
  users.users.${username}.home = "/Users/${username}";
  
  # Nix configuration
  nix.package = pkgs.nix;
  nix.settings = { 
    auto-optimise-store = false;
    experimental-features = "nix-command flakes";
  };
  nix.extraOptions = ''
    !include /etc/nix/nix.conf.before-nix-darwin
  '';
  
  # System configuration
  system.activationScripts.postActivation.text = ''
    # Ensure /etc/zshrc doesn't override our configuration
    sudo sed -i.bak -e '/^# Nix/,/^# End Nix/d' /etc/zshrc
  '';
}
