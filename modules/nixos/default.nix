# NixOS-specific modules
{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./services.nix
  ];
  
  # Common NixOS-specific settings
  # These will only be used when building for NixOS
}
