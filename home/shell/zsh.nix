# ZSH configuration
{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    # Automatically enter into a directory if typed directly into shell.
    autocd = true;
    autosuggestion = {
      enable = true;
      strategy = [ "history" ];
    };
    initExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    # This are automatically substituted in any part of a command
    # for example `ls -la @g downloads` becomes `ls -la | grep -i downloads`
    shellGlobalAliases = {
      "@g" = "| grep -i ";
      "~~" = "~/";
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
        };
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  # Common shell aliases
  home.shellAliases = rec {
    k = "kubectl";
    urldecode =
      "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode =
      "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    grep = "grep --color=auto";
    ".." = "cd ..";
    ls =
      "${pkgs.eza}/bin/exa --color=auto --group-directories-first --classify";
    lst = "${ls} --tree";
    la = "${ls} --all";
    ll = "${ls} --all --long --header --group";
    llt = "${ll} --tree";
    tree = "${ls} --tree";

  };
}
