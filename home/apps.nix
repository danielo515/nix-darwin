{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ast-grep # AST-based code search
    fd # A simple, fast and user-friendly alternative to find

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    wget

    # dev
    nixd # nix language server
    # productivity
    glow # markdown previewer in terminal
  ];

  services.syncthing.enable = true;

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };

    # terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    #Story your CLI history in a database synced across machines
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {filter_mode_shell_up_key_binding = "session";};
    };

    autojump = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    gh = {enable = true;};
    lazygit = {enable = true;};
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

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
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
        ];
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
    };

    navi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    pet = {
      enable = true;
    };
  };
}
