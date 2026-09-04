{
  config,
  ...
}: {
  # Link the bin directory from dotfiles to ~/.bin
  home.file.".bin".source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.path}/bin";

  # Update PATH to include the bin directory
  home.sessionVariables = {
    PATH = "$HOME/.bin:$PATH";
  };
}
