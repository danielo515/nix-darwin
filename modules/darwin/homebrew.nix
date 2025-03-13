# Darwin-specific Homebrew configuration
{ pkgs, ... }: {
  # Homebrew configuration
  # To make this work, homebrew needs to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
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

    taps = [ "homebrew/services" ];

    # `brew install`
    brews = [
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "aria2" # download tool
      "httpie" # http client
      "imagemagick"
    ];

    # `brew install --cask`
    casks = [
      "firefox@developer-edition"
      "google-chrome"
      "visual-studio-code"
      "windsurf"

      "anki"
      "iina" # video player
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats" # beautiful system monitor
      "keycastr" # display keyboard keys pressed

      # Development
      "wireshark" # network analyzer
      # "font-fira-code"
      # "font-inconsolata"
      # "font-inconsolata-nerd-font"
      # "font-hack-nerd-font"
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
      "monitorcontrol"
      "mos"
      "obs"
      "openscad"
      "orbstack"
      "orcaslicer"
      "steam"
      "upscayl"
      "utm" # full featured system emulator and virtual machine host
      "wezterm"
      "zed"
      "zoom"
      #"stremio"
      #"tableplus"
      #"ubersicht"
      #"maccy"
      #"podman-desktop"
      #"signal"
      #"slack"
    ];
  };
}
