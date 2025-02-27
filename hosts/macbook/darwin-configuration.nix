# Darwin-specific configuration for macbook
{ config, lib, pkgs, username, ... }:

{
  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # System configuration
  system.activationScripts.postActivation.text = ''
    # Ensure /etc/zshrc doesn't override our configuration
    sudo sed -i.bak -e '/^# Nix/,/^# End Nix/d' /etc/zshrc
  '';
}
