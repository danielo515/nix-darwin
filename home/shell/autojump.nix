# Autojump configuration - jump to frequently used directories
# https://github.com/wting/autojump
{ ... }: {
  programs.autojump = {
    enable = true;

    # Shell integrations register the chpwd hook that records visited
    # directories. Only sourced in interactive shells, so non-interactive
    # shells stay silent.
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  home.shellAliases = {
    # Interactive selection among matches (autojump's fzf-less equivalent
    # of `zi` is cycling with `j <partial>` then `j` again; keep a stats
    # helper for inspecting the database).
    autojump-stats = "autojump --stat";
  };
}
