# User configuration for Darwin
{ config, lib, pkgs, username, useremail, ... }:

{
  # Enable zsh
  programs.zsh.enable = true;
  
  # User configuration
  users.users.${username} = {
    # Darwin-specific user settings
    shell = pkgs.zsh;
    home = "/Users/${username}";
  };
}
