# Darwin-specific program configurations
{ pkgs, ... }: {
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
        font-size = 12;
        font-feature = [ "calt" "liga" "dlig" ];
        # font-variation-weight = 700; # Removed - unsupported field
        cursor-style = "block";
        cursor-style-blink = true;
        window-save-state = "always"; # Changed from 'true' to 'always'
        window-inherit-working-directory = true;
        macos-option-as-alt = true;
        mouse-hide-while-typing = true;
        # Disable ligatures when cursor is on them - removed unsupported field
        # font-disable-ligatures-in-cursor-line = true;
      };
    };
  };
}
