{
  lib,
  config,
  isDarwin,
  ...
}: {
  # Where this repo's dotfiles/ directory lives on the target machine, used
  # for out-of-store symlinks (live-editable config). Hosts that clone the
  # repo elsewhere override this in their own module.
  options.dotfiles.path = lib.mkOption {
    type = lib.types.str;
    default =
      if isDarwin
      then "/etc/nix-darwin/dotfiles"
      else "${config.home.homeDirectory}/.config/home-manager/dotfiles";
    description = "Absolute path to the repo's dotfiles directory for out-of-store symlinks";
  };
}
