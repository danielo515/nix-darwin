{
  config,
  dotfilesPath,
  ...
}: {
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hammerspoon";
  };
}
