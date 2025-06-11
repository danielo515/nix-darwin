{ lib, config, ... }: {
  options.aerospace = { enable = lib.mkEnableOption "aerospace"; };
  config = lib.mkIf config.aerospace.enable {
    home.file."${config.home.homeDirectory}/.aerospace.toml".source =
      config.lib.file.mkOutOfStoreSymlink
      /etc/nix-darwin/dotfiles/aerospace.toml;
  };
}
