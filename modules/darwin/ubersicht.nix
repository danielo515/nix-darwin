{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ubersicht;
  
  # Define Übersicht package
  uebersicht = pkgs.stdenv.mkDerivation {
    name = "uebersicht-1.6.82";
    buildInputs = [ pkgs.unzip pkgs.glibcLocales ];
    src = pkgs.fetchurl {
      url = "https://tracesof.net/uebersicht/releases/Uebersicht-1.6.82.app.zip";
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
in
{
  options.programs.ubersicht = {
    enable = lib.mkEnableOption "Übersicht desktop widget system";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.mkMerge [
      (lib.mapAttrs (_: _: {
        home.packages = [ uebersicht ];
      }) config.home-manager.users)
    ];
  };
}
