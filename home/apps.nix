{ config, pkgs, ... }:
let
  # Flags for the Ctrl+T file widget. --no-ignore because gitignored files
  # (.envrc, sibling repos under an ignoring parent, ...) should still be
  # pickable; noise dirs are excluded explicitly instead.
  fzf-fd-flags = "--hidden --no-ignore --exclude .git --exclude node_modules --exclude .direnv --exclude .DS_Store";
  # fzf transform for the Ctrl+T widget: each press walks the search root
  # one directory up (.., ../.., ...), tracking the current root in the prompt.
  fzf-walk-up = pkgs.writeShellScript "fzf-walk-up" ''
    root="''${FZF_PROMPT% > }/.."
    root="''${root#./}"
    printf 'change-prompt(%s > )+reload(fd ${fzf-fd-flags} . %s)' "$root" "$root"
  '';
in
{
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

    # cli tools
    bitwarden-cli # Password manager CLI

    # System utilities
    btop
    httpie
    tmux
    vim

  ];

  programs = {

    #a better cat alternative with fancy colors
    bat = {
      enable = true;
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
      shellWrapperName = "yy";
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
      flags = [ "--disable-up-arrow" ];
      # This are just plain settings from https://docs.atuin.sh/configuration/config
      settings = {
        filter_mode_shell_up_key_binding = "session";
        filter_mode = "directory";
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      fileWidgetCommand = "fd --strip-cwd-prefix ${fzf-fd-flags}";
      # ctrl-u re-roots the search one directory up per press (shadowing
      # fzf's default clear-query binding in this widget only); the prompt
      # shows the current root.
      fileWidgetOptions = [
        "--prompt '. > '"
        "--bind 'ctrl-u:transform:${fzf-walk-up}'"
      ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
    };

    pet = {
      enable = true;
    };
  };
}
