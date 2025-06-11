{ system, username, isDarwin, flake, ... }: {
  # Import common and platform-specific modules
  imports = [
    # Platform-specific configurations
    (if isDarwin then ./darwin else ./nixos)

    # Programs
    ./git.nix
    ./programs/neovim
    ./programs/tmux.nix
    ./programs/starship.nix
    # cross platform screenshots
    ./programs/flameshot.nix
    ./navi
    # Shell
    ./shell/common.nix
    ./shell/zsh.nix
    ./shell/bash.nix
    ./shell/wezterm.nix
    # Keep these until fully migrated
    ./apps.nix
  ];

  programs.fish.enable = true;
  aerospace.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = builtins.trace ">>> username:${username} <<<" username;
    homeDirectory =
      builtins.trace ">>> Setting homeDirectory in home/default.nix <<<"
      (if isDarwin then "/Users/${username}" else "/home/${username}");

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

  home.packages =
    [ flake.packages.${system}.hola flake.packages.${system}.repo-cloner ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
