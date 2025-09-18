# Zoxide configuration - A smarter cd command
# https://github.com/ajeetdsouza/zoxide
{ ... }: {
  programs.zoxide = {
    enable = true;
    
    # Enable shell integrations
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    
    # Options passed to zoxide init
    # Available options:
    # --cmd <CMD>     - Override the default command name (default: z)
    # --hook <HOOK>   - Set the hook type (prompt, pwd, none)
    # --no-cmd       - Don't add the z command (useful if you want to set up aliases manually)
    options = [
      # Use default command name 'z' and add 'cd' alias via shell aliases
      # "--cmd cd"  # This would make zoxide use 'cd' directly, but we prefer aliases for flexibility
    ];
  };

  # Shell aliases to make zoxide a complete substitute for cd
  home.shellAliases = {
    # Make cd use zoxide
    cd = "z";
    
    # Interactive directory selection with fzf-like interface
    cdi = "zi";
    
    # Additional useful zoxide aliases
    # Show zoxide database stats
    zoxide-stats = "zoxide query --list --score";
    
    # Remove a directory from zoxide database
    zoxide-remove = "zoxide remove";
    
    # Add current directory to zoxide database
    zoxide-add = "zoxide add .";
  };

  # Environment variables for zoxide configuration
  # These must be set before zoxide init is called
  home.sessionVariables = {
    # Print matched directory before navigating (useful for debugging)
    # "_ZO_ECHO" = "1";
    
    # Exclude certain directories from the database
    # "_ZO_EXCLUDE_DIRS" = "/tmp:/var/tmp";
    
    # Custom database location (default: ~/.local/share/zoxide)
    # "_ZO_DATA_DIR" = "${config.home.homeDirectory}/.config/zoxide";
    
    # Resolve symlinks when adding directories
    "_ZO_RESOLVE_SYMLINKS" = "1";
  };
}
