# Darwin-specific modules
{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./apps.nix
  ];
  
  # Darwin-specific user settings
  users.users.${username}.home = "/Users/${username}";
  
  # Darwin-specific Nix settings
  nix.extraOptions = ''
    !include /etc/nix/nix.conf.before-nix-darwin
  '';
  
  # Darwin state version
  system.stateVersion = 6;
  
  # Darwin-specific settings
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };
    
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
    };
    
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };
}
