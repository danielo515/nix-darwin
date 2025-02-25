{pkgs, ...}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
    sshs
    glow
    nushell
    nixfmt-classic
    age
    just # use Justfile to simplify nix-darwin's commands
  ];
  environment.variables.EDITOR = "nvim";

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      # Whether to enable Homebrew to auto-update itself and all formulae during nix-darwin system activation.
      # The default is false so that repeated invocations of darwin-rebuild switch are idempotent.
      autoUpdate = false;
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      # 'uninstall': just uninstalls what is not listed, but not related files
      cleanup = "uninstall";
    };

    taps = ["homebrew/services"];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "aria2" # download tool
      "httpie" # http client
      "imagemagick"
      "skhd"
      "yabai"
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "firefox@developer-edition"
      "google-chrome"
      "visual-studio-code"
      "windsurf"

      "anki"
      "iina" # video player
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats" # beautiful system monitor

      # Development
      "insomnia" # REST client
      "wireshark" # network analyzer
      "font-fira-code"
      "font-inconsolata"
      "font-inconsolata-nerd-font"
      "font-hack-nerd-font"
      "android-file-transfer"
      "balenaetcher"
      "blender"
      "bruno"
      "cyberduck"
      "diffusionbee"
      "docker"
      "freecad"
      "ghostty"
      "godot"
      "handbrake"
      "inkscape"
      "kitty"
      "lagrange"
      "losslesscut"
      "raycast"
      "monitorcontrol"
      "mos"
      "obs"
      "openscad"
      "orbstack"
      "orcaslicer"
      "steam"
      "upscayl"
      "utm"
      "wezterm"
      "zed"
      "zoom"
      #"stremio"
      #"tableplus"
      #"transmission"
      #"ubersicht"
      #"maccy"
      #"podman-desktop"
      #"qbittorrent"
      #"signal"
      #"slack"
    ];
  };
}
