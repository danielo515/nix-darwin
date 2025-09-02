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
    ./lsp.nix
    # auto format files
    ./conform.nix
    # show errors in the bufferline
    ./fidget.nix
    ./telescope.nix
  ];
  # Theme
  colorschemes.tokyonight.enable = true;

  # Use nixpkgs in sync with home manager.
  nixpkgs.useGlobalPackages = true;

  # Trying out the experimental lua loader.
  luaLoader.enable = true;

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
  globals = { mapleader = " "; };

  plugins = {
    # UI
    web-devicons.enable = true;
    which-key = { enable = true; };
    # Seamless navigation between Vim splits and tmux panes (Ctrl-h/j/k/l, Ctrl-\)
    tmux-navigator.enable = true;
    # depends on lps servers defined in ./lsp.nix
    schemastore = {
      enable = true;

      json = { enable = true; };

      yaml = { enable = true; };
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

    # Dev
    lazygit.enable = true;
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = { text = " "; };
          change = { text = " "; };
          delete = { text = " "; };
          untracked = { text = ""; };
          topdelete = { text = "󱂥 "; };
          changedelete = { text = "󱂧 "; };
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
