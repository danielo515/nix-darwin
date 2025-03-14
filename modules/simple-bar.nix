{ pkgs, lib, ... }:
let
  # Simple Bar Widget Installation Definition
  simpleBarWidget = pkgs.fetchFromGitHub {
    owner = "Jean-Tinland";
    repo = "simple-bar";
    rev = "master";
    sha256 =
      "sha256-Q+3wJQghCANGmQ+2VxFO7xCL2dTwHkCGikbOJeNqXEA="; # Replace with actual SHA256
  };
in {
  home = {
    # Set file locations for configuration files
    file = {
      # ".simplebarrc".source = ./dotfiles/.simplebarrc;
      # Install Simple Bar widget for Übersicht
      "Library/Application Support/Übersicht/widgets/simple-bar".source =
        simpleBarWidget;
    };
  };
}
