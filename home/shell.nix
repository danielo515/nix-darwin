{ ... }: {
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
    defaultKeymap = "vicmd";
    initExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    # This are automatically substituted in any part of a command
    # for example `ls -la @g downloads` becomes `ls -la | grep -i downloads`
    shellGlobalAliases = { "@g" = "| grep -i "; };
  };

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  home.shellAliases = {
    k = "kubectl";

    urldecode =
      "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode =
      "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
