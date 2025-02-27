{
  username,
  isDarwin,
  ...
}: {
  # Import common and platform-specific modules
  imports =
    [
      # Common configurations for all platforms
      ./common

      # Platform-specific configurations
      (
        if isDarwin
        then ./darwin
        else ./nixos
      )

      # Programs
      ./programs/git.nix
      ./programs/neovim.nix
      ./programs/tmux.nix
      ./programs/starship.nix
    ]
    # Darwin-specific programs
    ++ (
      if isDarwin
      then [./programs/hammerspoon.nix]
      else []
    )
    # Shell and other imports
    ++ [
      # Shell
      ./shell/zsh.nix
      ./shell/bash.nix

      # Keep these until fully migrated
      ./apps.nix
    ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = builtins.trace ">>> username:${username} <<<" username;
    homeDirectory =
      builtins.trace ">>> Setting homeDirectory in home/default.nix <<<"
      (
        if isDarwin
        then "/Users/${username}"
        else "/home/${username}"
      );

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
