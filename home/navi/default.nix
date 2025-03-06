{ config, pkgs, ... }:
let
  navi-settings = { cheats = { paths = [ "${./cheats}" ]; }; };
  yamlFormat = pkgs.formats.yaml { };
in {

  programs.

  navi = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = navi-settings;
  };
  # My temporal fix until https://github.com/nix-community/home-manager/issues/6559
  home.file."${config.xdg.configHome}/navi/config.yaml".source =
    yamlFormat.generate "navi-config" navi-settings;
}
