# NixOS services configuration
{ config, lib, pkgs, ... }:

{
  # Services configuration for NixOS
  # These will only be used when building for NixOS
  
  # Example: Enable SSH server
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "no";
  #     PasswordAuthentication = false;
  #   };
  # };
  
  # Example: Enable Printing
  # services.printing = {
  #   enable = true;
  #   drivers = [ pkgs.gutenprint pkgs.hplip ];
  # };
}
