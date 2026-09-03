{
  lib,
  config,
  pkgs,
  dotfilesPath,
  ...
}: {
  options.aerospace = { enable = lib.mkEnableOption "aerospace"; };
  config = lib.mkIf config.aerospace.enable {
    home.file."${config.home.homeDirectory}/.aerospace.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/aerospace.toml";

    # The running AeroSpace server keeps serving the old socket protocol after
    # an update, breaking the CLI and window management. onChange fires only
    # when the store path in this file changes, i.e. on actual updates.
    home.file.".local/state/aerospace-store-path" = {
      text = pkgs.aerospace.outPath;
      onChange = ''
        if /usr/bin/pgrep -xq AeroSpace; then
          echo "AeroSpace was updated; restarting it"
          /usr/bin/killall AeroSpace || true
          sleep 2
          /usr/bin/open -a AeroSpace
        fi
      '';
    };
  };
}
