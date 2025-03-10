# Neovim configuration managed using https://github.com/nix-community/nixvim
{
  imports = [
    ./lualine.nix
    ./startup.nix
    ./bufferline.nix
    ./cmp.nix
    ./navic.nix
    ./neo-tree.nix
    ./treesitter.nix
    # auto format files
    ./conform.nix
    # show errors in the bufferline
    ./fidget.nix
  ];
  # Theme
  colorschemes.tokyonight.enable = true;

  # Settings
  opts = {
    expandtab = true;
    shiftwidth = 2;
    smartindent = true;
    tabstop = 2;
    number = true;
    clipboard = "unnamedplus";
  };

  # Keymaps
  globals = {
    mapleader = " ";
  };

  plugins = {
    # UI
    web-devicons.enable = true;
    which-key = {
      enable = true;
    };
    # depends on lps servers defined in ./lsp.nix
    schemastore = {
      enable = true;

      json = {
        enable = true;
      };

      yaml = {
        enable = true;
      };
    };
    noice = {
      # WARNING: This is considered experimental feature, but provides nice UX
      enable = true;
      settings.presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        #inc_rename = false;
        #lsp_doc_border = false;
      };
    };
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          options.desc = "file finder";
          action = "find_files";
        };
        "<leader>fg" = {
          options.desc = "find via grep";
          action = "live_grep";
        };
      };
      extensions = {
        file-browser.enable = true;
      };
    };

    # Dev
    lsp = {
      enable = true;
      servers = {
        hls = {
          enable = true;
          installGhc = false; # Managed by Nix devShell
        };
        marksman.enable = true;
        nil_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
      };
    };
    lazygit.enable = true;
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = {
            text = " ";
          };
          change = {
            text = " ";
          };
          delete = {
            text = " ";
          };
          untracked = {
            text = "";
          };
          topdelete = {
            text = "󱂥 ";
          };
          changedelete = {
            text = "󱂧 ";
          };
        };
      };
    };
  };
  keymaps = [
    # Open lazygit within nvim.
    {
      action = "<cmd>LazyGit<CR>";
      key = "<leader>gg";
    }
    {
      action = "<cmd>w<CR>";
      key = "<leader>w";
      options.desc = "save buffer";
    }
  ];
}
