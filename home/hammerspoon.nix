{
  config,
  xdg,
  ...
}: {
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon".source =
      config.lib.file.mkOutOfStoreSymlink /etc/nix-darwin/dotfiles/hammerspoon;
  };
  # xdg.configFile."hammerspoon".source =
  #       config.lib.file.mkOutOfStoreSymlink /etc/nix-darwin/dotfiles/hammerspoon;
}
