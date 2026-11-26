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
    # Claude Code + CodeCompanion agent integration
    ./ai.nix
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
    # Pick up edits made outside nvim (agents writing to disk) instead of
    # holding a stale buffer; the :checktime autocmd in ./ai.nix triggers it.
    autoread = true;
    winborder = "rounded";
    # No terminals: restoring one reruns its command, e.g. a stray claude next to claudecode.nvim's split.
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize";
  };

  # Keymaps
  globals = {
    mapleader = " ";
    maplocalleader = ",";
  };

  # Workaround for neovim 0.12 + VS Code/Windsurf terminal: xterm.js mis-encodes
  # the kitty keyboard protocol, breaking Shift+digit (e.g. Shift+3 yields 3, not #).
  # Pop the protocol flags so the terminal falls back to legacy encoding.
  # Scoped to the VS Code/Windsurf terminal; other terminals keep the protocol.
  # See neovim/neovim#38651, xtermjs/xterm.js#5823.
  extraConfigLua = ''
    if vim.env.TERM_PROGRAM == "vscode" then
      vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
        callback = function()
          io.stdout:write("\27[<u")
        end,
      })
    end
  '';

  # ~/.config/nvim/init.lua tracks the active home-manager generation, so a
  # restart after darwin-rebuild loads the new config; the session keeps layout.
  userCommands.Reload = {
    desc = "Restart nvim with the latest config, keeping windows and buffers";
    command.__raw = ''
      function()
        local session = vim.fn.stdpath("state") .. "/reload-session.vim"
        vim.cmd.mksession({ session, bang = true })
        if vim.g.reload_loop == 1 then
          local unsaved = vim.tbl_filter(function(buf)
            return vim.bo[buf].buflisted and vim.bo[buf].modified
          end, vim.api.nvim_list_bufs())
          if #unsaved > 0 then
            vim.notify("Reload: save or discard changes first", vim.log.levels.ERROR)
            return
          end
          local running_terminals = vim.tbl_filter(function(buf)
            return vim.bo[buf].buftype == "terminal" and vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1] == -1
          end, vim.api.nvim_list_bufs())
          if #running_terminals > 0 and not opts.bang then
            vim.notify("Reload: terminals are still running (e.g. Claude); use :Reload! to close them", vim.log.levels.ERROR)
            return
          end
          vim.cmd.mksession({ session, bang = true })
          vim.cmd("cquit 75")
          return
        end
        -- :restart reuses this process's command line, which pins the plugin folder it started with.
        local pack_dir = function(text) return text:match("/nix/store/[^%s,\"']*vim%-pack%-dir") end
        local running = pack_dir(table.concat(vim.v.argv, " "))
        local wrapper = vim.fn.resolve(vim.fn.exepath("nvim"))
        local latest = wrapper ~= "" and pack_dir(table.concat(vim.fn.readfile(wrapper), "\n"))
        if running and latest and running ~= latest then
          vim.notify("Reload: plugins changed since this nvim started; quit and reopen it", vim.log.levels.ERROR)
          return
        end
        -- Wait for startup.nvim's deferred cursor move on its welcome page before loading the session.
        vim.cmd("restart lua vim.defer_fn(function() vim.cmd.source(" .. string.format("%q", session) .. ") end, 50)")
      end
    '';
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
        lsp_doc_border = true;
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
