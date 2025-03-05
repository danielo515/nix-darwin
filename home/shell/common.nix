{ pkgs, ... }: {

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
