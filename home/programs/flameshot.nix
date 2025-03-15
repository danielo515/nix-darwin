# flameshot is a free,open source and cross platform screenshot manager
{ pkgs, username, lib, ... }:
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
    "raycast/flameshot".text = ''
      #!/bin/bash

      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title flameshot
      # @raycast.mode silent

      # Optional parameters:
      # @raycast.icon 🤖
      # @raycast.packageName danielo.flameshot

      # Documentation:
      # @raycast.description Take an screenshot using flameshot
      # @raycast.author danielo
      # @raycast.authorURL https://raycast.com/danielo

      ${lib.getExe pkgs.flameshot} gui'';
  };
}
