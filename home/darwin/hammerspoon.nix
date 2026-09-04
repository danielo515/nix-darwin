{
  config,
  ...
}: {
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.path}/hammerspoon";
  };
}
