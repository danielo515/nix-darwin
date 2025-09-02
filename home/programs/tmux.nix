# Tmux configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    tmuxp.enable = true;

    extraConfig = ''
      # Set default shell
      set-option -g default-shell "${pkgs.zsh}/bin/zsh"
      set-option -g default-command "${pkgs.zsh}/bin/zsh"

      # Set terminal to support colors
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      # Set history limit
      set -g history-limit 10000

      # Set vi-style key bindings
      setw -g mode-keys vi
      set -g status-keys vi            # Use vi keys in the status line/prompt

      # Enable mouse support
      set -g mouse on

      # Sensible behavior
      set -g focus-events on           # Let apps know when pane gains/loses focus
      set -g renumber-windows on       # Keep window numbers contiguous after close
      set -g set-clipboard on          # Sync tmux copy with system clipboard
      set -g display-time 1000         # Shorter on-screen messages (ms)
      set -g assume-paste-time 1       # Faster bracketed paste detection
      set -g detach-on-destroy off     # Don't detach session when last window closes

      # Status bar customization
      set -g status-style bg=default
      set -g status-left "#[fg=blue]#S #[fg=white]| "
      set -g status-right "#[fg=white]%H:%M #[fg=white]%d-%b-%y"
      set -g status-justify left

      # Window status
      set -g window-status-current-style fg=green,bold
      set -g window-status-style fg=white

      # Pane borders
      set -g pane-border-style fg=white
      set -g pane-active-border-style fg=green
      set -g pane-border-format " [ ###P #T ] "
      set -g pane-border-status top # This line is required to make the one above work

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Navigate panes using vim-like keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Better copy-mode (vi)
      bind -T copy-mode-vi v send -X begin-selection        # Start selection like Vim visual mode
      bind -T copy-mode-vi y send -X copy-selection-and-cancel  # Yank selection to clipboard and exit
      bind -T copy-mode-vi Y send -X copy-end-of-line       # Yank to end of line
    '';

    plugins = with pkgs.tmuxPlugins; [
      yank # Better system clipboard integration
      resurrect # Save/restore tmux sessions
      continuum # Auto-save/restore (works with resurrect)
      vim-tmux-navigator # Seamless Vim/Neovim <-> tmux pane navigation
    ];
  };
}
