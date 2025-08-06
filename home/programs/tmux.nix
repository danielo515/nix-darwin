# Tmux configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    shortcut = "a";
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    tmuxp.enable = true;

    extraConfig = ''
      # Set terminal to support colors
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

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
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];
  };
}
