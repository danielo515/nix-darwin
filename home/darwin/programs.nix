# Darwin-specific program configurations
{pkgs, ...}: {
  programs = {
    # Terminal emulator for macOS
    ghostty = {
      enable = true;
      # Let brew manage the package
      package = null;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      # Not allowed when package is null
      # installBatSyntax = true;
      # installVimSyntax = true;

      settings = {
        background-blur-radius = 20;
        theme = "dark:catppuccin-mocha,light:catppuccin-latte";
        window-theme = "dark";
        background-opacity = 0.85;
        minimum-contrast = 1.1;
        keybind = [
          # keybind = global:ctrl+`=toggle_quick_terminal
          "global:ctrl+grave_accent=toggle_quick_terminal"
        ];
        font-family = "JetBrainsMono Nerd Font";
        font-size = 14;
        font-feature = [
          "calt"
          "liga"
          "dlig"
        ];
        font-variation-weight = 700;
        cursor-style = "block";
        cursor-style-blink = false;
        window-save-state = true;
        window-inherit-working-directory = true;
        macos-option-as-alt = true;
        mouse-hide-while-typing = true;
        # Disable ligatures when cursor is on them
        font-disable-ligatures-in-cursor-line = true;
      };
    };
  };

  # Enable Syncthing service
  services.syncthing.enable = true;
}
