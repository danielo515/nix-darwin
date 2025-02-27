# Common home-manager configurations for all environments
{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
  ];
}
