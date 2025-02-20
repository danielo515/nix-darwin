{ pkgs, ... }: {

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
    direnv
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
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    taps = [ "homebrew/services" ];

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
      #"maccy"
      "monitorcontrol"
      "mos"
      "obs"
      "openscad"
      "orbstack"
      "orcaslicer"
      #"podman-desktop"
      #"qbittorrent"
      "raycast"
      #"signal"
      #"slack"
      "steam"
      #"stremio"
      #"tableplus"
      #"transmission"
      #"ubersicht"
      "upscayl"
      "utm"
      "wezterm"
      "zed"
      "zoom"
    ];
  };
}
