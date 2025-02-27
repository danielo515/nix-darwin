# Git configuration
{ config, lib, pkgs, username, useremail, ... }:

{
  programs.git = {
    enable = true;
    userName = username;
    userEmail = useremail;
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      ci = "commit";
      br = "branch";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };
    
    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".vscode"
      ".idea"
    ];
  };
}
