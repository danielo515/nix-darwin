# Common packages for all environments
{pkgs, ...}: {
  # Packages to be installed in the user's environment
  home.packages = with pkgs; [
    # Development tools
    git
    gh
    gnumake
    cmake
    gcc
    nodejs
    python3
    nixd # nix language server

    # System utilities
    htop
    btop
    ripgrep
    fd
    jq
    tree
    wget
    curl
    unzip

    # archives
    zip
    unzip

    # utils
    ripgrep
    jq
    yq-go
    eza
    bat
    fd

    # networking tools
    httpie

    # Text processing
    vim
    neovim

    # Version control
    git-lfs

    # Terminal enhancements
    tmux

    # productivity
    glow # markdown previewer in terminal
  ];
}
