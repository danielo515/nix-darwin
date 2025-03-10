# Why can't I use pkgs.stdenv.isDarwin instead of the specialArg isDarwin
{ pkgs, isDarwin, ... }:
let
  extraConfig = ''
    local config = {}
    if wezterm.config_builder then
      config = wezterm.config_builder()
    end

    config.color_scheme = 'Gruvbox Dark (Gogh)'
    config.enable_tab_bar = true
    config.font = wezterm.font 'JetBrains Mono'
    -- config.term = 'wezterm'
    config.window_padding = { left = 2, right = 2, top = 2, bottom = 2, }
    config.animation_fps = 1
    config.cursor_blink_ease_in = 'Constant'
    config.cursor_blink_ease_out = 'Constant'
    config.front_end = 'WebGpu'

    return config
  '';
in
# in darwin, installing wezterm using home-manager leads to a problem
# where it opens the wrong binary. Maybe there is some workaround in the nix community
# that I have to investigate
if isDarwin then
  {
    xdg.configFile."wezterm/wezterm.lua".text = ''
      local wezterm = require("wezterm")
      ${extraConfig}
    '';
    # homebrew.casks = [ "wezterm" ];
    # I wanted this to be here, but this is a HM module
  }
else
  {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      extraConfig = extraConfig;
    };
  }
