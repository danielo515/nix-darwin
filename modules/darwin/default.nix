# Darwin-specific modules
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [./apps.nix ./system.nix];

  # Darwin-specific Nix settings
  nix.extraOptions =
    builtins.trace
    ">>> Setting nix.extraOptions in modules/darwin/default.nix <<<" ''
      !include /etc/nix/nix.conf.before-nix-darwin
    '';

  # Darwin state version
  system.stateVersion =
    builtins.trace
    ">>> Setting system.stateVersion in modules/darwin/default.nix <<<"
    6;
}
