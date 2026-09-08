# Why can't I use pkgs.stdenv.isDarwin instead of the specialArg isDarwin
{ pkgs, isDarwin, ... }:
let
  extraConfig = ''
    local config = {}
    if wezterm.config_builder then
      config = wezterm.config_builder()
    end

    config.color_scheme = 'Catppuccin Mocha'
    config.enable_tab_bar = true
    config.use_fancy_tab_bar = false
    config.hide_tab_bar_if_only_one_tab = true
    config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
    config.font_size = 12
    config.harfbuzz_features = { 'calt', 'liga', 'dlig' }
    config.window_background_opacity = 0.93
    config.macos_window_background_blur = 20
    config.window_decorations = 'RESIZE'
    config.default_cursor_style = 'BlinkingBlock'
    config.hide_mouse_cursor_when_typing = true
    config.send_composed_key_when_left_alt_is_pressed = false
    local function describe(action)
      return (tostring(action):gsub('^Action%(', ""):gsub('%)$', ""))
    end

    local function show_hotkeys(window, pane)
      local seen, choices = {}, {}
      local function add(mods, key, action)
        local combo = (mods ~= 'NONE' and mods ~= "" and (mods:gsub('|', '+') .. '+') or "") .. key
        if seen[combo] then return end
        seen[combo] = true
        table.insert(choices, { id = combo, label = string.format('%-22s %s', combo, describe(action)) })
      end
      for _, k in ipairs(config.keys or {}) do add(k.mods or 'NONE', k.key, k.action) end
      for _, k in ipairs(wezterm.gui.default_keys()) do add(k.mods, k.key, k.action) end
      table.sort(choices, function(a, b) return a.id < b.id end)
      window:perform_action(
        wezterm.action.InputSelector {
          title = 'Hotkeys',
          fuzzy = true,
          choices = choices,
          action = wezterm.action_callback(function() end),
        },
        pane
      )
    end

    config.keys = {
      { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },
      { key = 'p', mods = 'SUPER|SHIFT', action = wezterm.action_callback(show_hotkeys) },
      {
        key = 'r',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.PromptInputLine {
          description = 'Rename tab',
          action = wezterm.action_callback(function(window, pane, line)
            if line then
              window:active_tab():set_title(line)
            end
          end),
        },
      },
    }
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
