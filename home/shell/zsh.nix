# ZSH configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    # Keep .zcompdump out of $HOME — stash it under ~/.cache/zsh.
    completionInit = ''
      [[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"
      autoload -U compinit
      compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
    '';
    # Automatically enter into a directory if typed directly into shell.
    autocd = true;
    history.share = false;
    autosuggestion = {
      enable = true;
      strategy = ["history"];
    };
    initContent = let
      atuinWorkaround = lib.optionalString (config.programs.atuin.enable) ''
        function zvm_after_init() {
          # Re-source fzf keybindings after vi-mode overrides them.
          # Must run BEFORE the atuin bindings — fzf's integration rebinds ^R
          # to fzf-history-widget, which would clobber atuin otherwise.
          eval "$(fzf --zsh)"
          zvm_bindkey viins '^R' atuin-search
          zvm_bindkey vicmd '^R' atuin-search
        }
      '';
    in ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      # Make sure brew is on the path for M1
      if [[ $(uname -m) == 'arm64' ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      ${atuinWorkaround}

      # Auto-switch gh config for yuvod directory
      autoload -U add-zsh-hook
      _gh_switch_config() {
        if [[ "$PWD" == "$HOME/GIT/yuvod"* ]]; then
          export GH_CONFIG_DIR="$HOME/GIT/yuvod/.gh"
        else
          unset GH_CONFIG_DIR
        fi
      }
      add-zsh-hook chpwd _gh_switch_config
      _gh_switch_config  # Run on shell startup

      # fzf-tab configuration
      # Disable sort when completing `git checkout` (keep branch order).
      zstyle ':completion:*:git-checkout:*' sort false
      # Show file previews when completing cd / paths.
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath 2>/dev/null || command ls -G $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && (ls --color $realpath 2>/dev/null || command ls -G $realpath) || ([[ -f $realpath ]] && (bat --color=always --line-range=:200 $realpath 2>/dev/null || cat $realpath))'
      # Use Tab to switch groups, Shift-Tab to go back.
      zstyle ':fzf-tab:*' switch-group ',' '.'
      # When tmux is running, render the menu in a floating popup.
      zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
      # Git branch completions: no preview, popup as wide as the window allows.
      zstyle ':fzf-tab:complete:(git-checkout|git-switch|git-merge|git-rebase|git-branch|git-log|git-diff|git-show|git-cherry-pick|git-reset):*' fzf-preview '''
      zstyle ':fzf-tab:complete:(git-checkout|git-switch|git-merge|git-rebase|git-branch|git-log|git-diff|git-show|git-cherry-pick|git-reset):*' fzf-flags --preview-window=hidden
      zstyle ':fzf-tab:complete:(git-checkout|git-switch|git-merge|git-rebase|git-branch|git-log|git-diff|git-show|git-cherry-pick|git-reset):*' popup-min-size 999 15
      # Accept the current selection with Enter (so first Tab can preview).
      zstyle ':fzf-tab:*' accept-line enter

      # Initialize zoxide LAST so its precmd hook is registered after every
      # other plugin (vi-mode, gh-switch, etc). Required to silence the
      # `_ZO_DOCTOR` warning. See home/shell/zoxide.nix for why
      # enableZshIntegration is disabled there.
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    '';
    # This are automatically substituted in any part of a command
    # for example `ls -la @g downloads` becomes `ls -la | grep -i downloads`
    shellGlobalAliases = {
      "@g" = "| grep -i ";
      "~~" = "~/";
    };

    plugins = [
      # fzf-tab must load AFTER compinit (handled via completionInit above)
      # and BEFORE widget-wrapping plugins like zsh-autosuggestions / syntax-highlighting.
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
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
      # This plugin introduces problems with atuin control+r hooks
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };
}
