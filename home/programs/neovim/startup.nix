{
  # One session per directory and git branch, restored from the startup menu.
  plugins.persistence.enable = true;

  plugins.startup = {
    enable = true;

    settings = {
      colors = {
        background = "#ffffff";
        folded_section = "#ffffff";
      };

      header = {
        type = "text";
        oldfilesDirectory = false;
        align = "center";
        foldSection = false;
        title = "Header";
        margin = 5;
        content = [
          " ██████╗░░█████╗░███╗░░░██╗██╗███████╗██╗░░░░░░██████╗░"
          " ██╔══██╗██╔══██╗████╗░░██║██║██╔════╝██║░░░░░██╔═══██╗"
          " ██║░░██║███████║██╔██╗░██║██║█████╗░░██║░░░░░██║░░░██║"
          " ██║░░██║██╔══██║██║╚██╗██║██║██╔══╝░░██║░░░░░██║░░░██║"
          " ██████╔╝██║░░██║██║░╚████║██║███████╗███████╗╚██████╔╝"
          " ╚═════╝░╚═╝░░╚═╝╚═╝░░╚═══╝╚═╝╚══════╝╚══════╝░╚═════╝░"
        ];
        highlight = "Statement";
        defaultColor = "";
        oldfilesAmount = 0;
      };

      body = {
        type = "mapping";
        oldfilesDirectory = false;
        align = "center";
        foldSection = false;
        title = "Menu";
        margin = 5;
        content = [
          [ "󰦛 Restore Session" "lua require('persistence').load()" "r" ]
          [ "󱂬 Pick Session" "lua require('persistence').select()" "R" ]
          [ "󰈞 Find File" "Telescope find_files" "ff" ]
          [ "󰊄 Find Word" "FzfLua live_grep" "fr" ]
          [ "󰋚 Recent Files" "Telescope oldfiles" "fg" ]
          [ "󰙅 File Browser" "Telescope file_browser" "fe" ]
        ];
        highlight = "string";
        defaultColor = "";
        oldfilesAmount = 0;
      };

      options = { paddings = [ 1 3 ]; };

      parts = [ "header" "body" ];
    };
  };
}
