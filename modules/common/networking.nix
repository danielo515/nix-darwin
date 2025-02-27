# Common networking configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Common networking configuration
  networking = {
    # Firewall configuration
    # firewall.enable = true;
  };

  # Network-related packages
  environment.systemPackages = with pkgs; [nmap wget curl aria2];
}
