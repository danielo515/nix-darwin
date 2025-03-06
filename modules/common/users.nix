# User configuration for all platforms
{ pkgs, username, isDarwin, ... }: {
  # Enable zsh
  programs.zsh.enable = true;

  # User configuration with platform-specific home directory
  users.users.${username} = {
    shell = pkgs.zsh;
    home = builtins.trace
      ">>> Setting home directory in modules/common/users.nix <<<"
      (if isDarwin then "/Users/${username}" else "/home/${username}");
  };
}
