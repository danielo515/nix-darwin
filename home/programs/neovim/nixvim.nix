# Neovim configuration managed using https://github.com/nix-community/nixvim
{
  imports = [
    ./lualine.nix
    ./startup.nix
    ./bufferline.nix
    ./blink-cmp.nix
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
  globals = {
    mapleader = " ";
    maplocalleader = ",";
  };

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
        on_attach = ''
          function(bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            map('n', ']c', function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() gs.nav_hunk('next') end)
              return '<Ignore>'
            end, { expr = true, desc = "Next git hunk" })
            map('n', '[c', function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() gs.nav_hunk('prev') end)
              return '<Ignore>'
            end, { expr = true, desc = "Previous git hunk" })

            -- Hunk actions under ,h (localleader)
            local ok, wk = pcall(require, 'which-key')
            if ok then wk.add({ { '<localleader>h', group = 'Git hunks', mode = { 'n', 'v' }, buffer = bufnr } }) end
            map('n', '<localleader>hn', function() gs.nav_hunk('next') end, { desc = "Next hunk" })
            map('n', '<localleader>hN', function() gs.nav_hunk('prev') end, { desc = "Previous hunk" })
            map('n', '<localleader>hs', gs.stage_hunk, { desc = "Stage hunk" })
            map('n', '<localleader>hr', gs.reset_hunk, { desc = "Reset hunk" })
            map('v', '<localleader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Stage hunk" })
            map('v', '<localleader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Reset hunk" })
            map('n', '<localleader>hp', gs.preview_hunk, { desc = "Preview hunk" })
            map('n', '<localleader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
            map('n', '<localleader>hd', gs.diffthis, { desc = "Diff this" })
            map('n', '<localleader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          end
        '';
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
    # Diagnostics (localleader = ,)
    {
      mode = "n";
      key = "<localleader>d";
      action.__raw = "function() vim.diagnostic.goto_next() end";
      options.desc = "Next diagnostic";
    }
    {
      mode = "n";
      key = "<localleader>D";
      action.__raw = "function() vim.diagnostic.goto_prev() end";
      options.desc = "Previous diagnostic";
    }
    {
      mode = "n";
      key = "<localleader>e";
      action.__raw = "function() vim.diagnostic.open_float() end";
      options.desc = "Show diagnostic (error) under cursor";
    }
    {
      mode = "n";
      key = "<localleader>q";
      action.__raw = "function() vim.diagnostic.setloclist() end";
      options.desc = "Diagnostics to loclist";
    }
  ];
}
