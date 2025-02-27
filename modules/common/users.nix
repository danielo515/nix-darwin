# Common user configuration
{ config, lib, pkgs, username, useremail, ... }:

{
  users.groups.${username} = { };
  programs.zsh.enable = true;
  # User configuration
  users.users.${username} = {
    # Common user settings
    shell = pkgs.zsh;
    group = username;
    isNormalUser = true;
  };
}
