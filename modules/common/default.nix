# Common modules for all systems
{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./networking.nix
    ./users.nix
    ./nix-core.nix
  ];
}
