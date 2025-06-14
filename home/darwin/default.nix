# Darwin-specific home-manager configurations
{ pkgs, config, ... }:
let
  # Define Übersicht package
  uebersicht = pkgs.stdenv.mkDerivation {
    name = "uebersicht-1.6.82";
    buildInputs = [ pkgs.unzip pkgs.glibcLocales ];
    src = pkgs.fetchurl {
      url =
        "https://tracesof.net/uebersicht/releases/Uebersicht-1.6.82.app.zip";
      sha256 = "sha256-OdteCr8D9jkJklEclGwZuXqJ+E6+KshyGev5If/7lys=";
    };

    unpackPhase = ''
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/Applications
      cp -R "Übersicht.app" $out/Applications/
    '';
  };
in {
  imports = [
    ./ghostty.nix
    ./hammerspoon.nix
    ../../modules/simple-bar.nix
    ./bin.nix
    ./aerospace.nix
  ];

  # Darwin-specific configurations
  home.packages = with pkgs; [
    # macOS-specific packages
    m-cli # useful macOS CLI commands
    mas # Mac App Store CLI
    sketchybar
    jankyborders
    uebersicht
  ];

  xdg.configFile.sketchybar.source = ../../dotfiles/sketchybar;

}
