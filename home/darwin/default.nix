# Darwin-specific home-manager configurations
{pkgs, ...}: let
  # nixpkgs' swipeaerospace (0.3.1) predates upstream's AeroSpace 0.21 socket
  # protocol compatibility fix, so the swipe gesture is detected but the
  # workspace switch silently fails against our AeroSpace 0.21.3-Beta.
  # Bump to v0.3.3, which includes that fix.
  swipeaerospace = pkgs.swipeaerospace.overrideAttrs (old: rec {
    version = "0.3.3";
    src = pkgs.fetchFromGitHub {
      owner = "MediosZ";
      repo = "SwipeAeroSpace";
      tag = "v${version}";
      hash = "sha256-lEWbZ/FvxtlY4VnFRk//tDeVrW9+udyJ+hbUsG61jhI=";
    };
  });
in {
  imports = [
    ./ghostty.nix
    ./hammerspoon.nix
    ../../modules/simple-bar.nix
    ./bin.nix
    ./aerospace.nix
  ];

  # Darwin-specific configurations
  home.packages = (with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
    sketchybar
    jankyborders
  ]) ++ [
    swipeaerospace # trackpad swipe gestures to switch AeroSpace workspaces
  ];

  xdg.configFile.sketchybar.source = ../../dotfiles/sketchybar;
}
