# This file exports all packages defined in this directory
{ pkgs }:

{
  repo-cloner = pkgs.callPackage ./repo-cloner { };
}
