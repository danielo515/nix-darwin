{
  config,
  dotfilesPath,
  ...
}: {
  # worktrunk itself is installed via Homebrew (not in nixpkgs yet); this
  # just manages its config as a dotfile like everything else.
  xdg.configFile."worktrunk/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
    "${dotfilesPath}/worktrunk.toml";
}
