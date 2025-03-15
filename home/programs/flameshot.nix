# flameshot is a free,open source and cross platform screenshot manager
{ pkgs, username, ... }:
let
  savePath = "${
      if pkgs.stdenv.isDarwin then "/Users" else "/home"
    }/${username}/screenshots";
in {
  # Ensure flameshot package installed
  home.packages = with pkgs; [ flameshot ];

  xdg.configFile = {
    "flameshot/flameshot.ini" = {
      text = pkgs.lib.generators.toINI { } {
        General = {
          disabledTrayIcon = true;
          contrastOpacity = 96;
          drawColor = "#ff2800";
          drawFontSize = 4;
          saveAsFileExtension = ".png";
          savePath = savePath;
          savePathFixed = true;
          showDesktopNotification = false;
          showHelp = false;
          showMagnifier = true;
          showStartupLaunchMessage = false;
          squareMagnifier = true;
          startupLaunch = true;
          uiColor = "#8aadf4";
        };
      };
    };
  };
}
