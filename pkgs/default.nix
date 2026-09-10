# This file exports all packages defined in this directory
{ pkgs }:

{
  repo-cloner = pkgs.callPackage ./repo-cloner { 
    inherit (pkgs) git gum; 
  };
  zombies = pkgs.callPackage ./zombies {};
}
