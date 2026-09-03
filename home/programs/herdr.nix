{
  lib,
  config,
  pkgs,
  flake,
  ...
}: let
  herdr = flake.inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  plugins = [
    "smarzban/herdr-file-viewer"
    "persiyanov/herdr-reviewr"
  ];
in {
  options.herdr = {enable = lib.mkEnableOption "herdr";};
  config = lib.mkIf config.herdr.enable {
    home.packages = [
      herdr
      # Renderers used by herdr-file-viewer
      pkgs.glow
      pkgs.delta
      pkgs.bat
    ];
    xdg.configFile."herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      /etc/nix-darwin/dotfiles/herdr.toml;
    xdg.configFile."herdr/jump.sh" = {
      source = ../../dotfiles/herdr-jump.sh;
      executable = true;
    };
    xdg.configFile."herdr/plugins/config/persiyanov.reviewr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      /etc/nix-darwin/dotfiles/herdr-reviewr.toml;
    home.activation.herdrPlugins = lib.hm.dag.entryAfter ["writeBoundary"] (
      lib.concatMapStringsSep "\n" (plugin: let
        id = builtins.baseNameOf plugin;
      in ''
        if ! ${herdr}/bin/herdr plugin list 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "${id}"; then
          run env PATH="${lib.makeBinPath (with pkgs; [git curl gawk gnused gnutar gzip coreutils])}:$PATH" \
            ${herdr}/bin/herdr plugin install "${plugin}" --yes || verboseEcho "herdr plugin install failed for ${plugin}"
        fi
      '')
      plugins
    );
  };
}
