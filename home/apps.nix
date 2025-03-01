{ config, pkgs, ... }:
let
  navi-settings = { cheats = { paths = [ "${../home/cheats}" ]; }; };
  yamlFormat = pkgs.formats.yaml { };
in {
  home.packages = with pkgs; [
    # dev
    nixd # nix language server

    # misc
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    ast-grep # AST-based code search
    file
    fd # A simple, fast and user-friendly alternative to find
    gawk
    glow # markdown previewer in terminal
    htop
    jq # A lightweight and flexible command-line JSON processor
    nmap # A utility for network discovery and security auditing
    ripgrep # recursively searches directories for a regex pattern
    socat # replacement of openbsd-netcat
    wget
    yq-go # yaml processer https://github.com/mikefarah/yq

    # System utilities
    btop
    httpie
    tmux
    vim

  ];

  services.syncthing.enable = true;

  programs = {

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
      settings = { filter_mode_shell_up_key_binding = "session"; };
    };

    autojump = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    gh = { enable = true; };
    lazygit = { enable = true; };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
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
      settings = navi-settings;
    };
    pet = { enable = true; };
  };
  # My temporal fix until https://github.com/nix-community/home-manager/issues/6559
  home.file."${config.xdg.configHome}/navi/config.yaml".source =
    (yamlFormat.generate "navi-config" navi-settings);
}
