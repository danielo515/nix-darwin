{ config, lib, pkgs, ... }:
let
  luaExpr = s:
    let
      prefix = builtins.substring 0 7 s;
      check = lib.assertMsg (prefix == "return ")
        "Lua expressions must begin with `return '";
    in assert check; builtins.substring 7 (-1) s;
  luaRawExpr = s: { __raw = luaExpr s; };
  luaRaw = s: { __raw = s; };

in {
  programs.nixvim = {
    plugins.fzf-lua = {
      enable = true;
      settings = {
        fzf_opts = { "--no-scrollbar" = true; };
        defaults = {
          file_icons = "mini";
          keymap = {
            fzf = {
              "ctrl-q" = "select-all+accept";
              "ctrl-u" = "half-page-up";
              "ctrl-d" = "half-page-down";
              "ctrl-x" = "jump";
              "ctrl-f" = "preview-page-down";
              "ctrl-b" = "preview-page-up";
            };
            builtin = {
              "<c-f>" = "preview-page-down";
              "<c-b>" = "preview-page-up";
            };
          };
        };
        previewers = {
          builtin = {
            extensions =
              let image_preview = [ "chafa" "{file}" "--format=symbols" ];
              in {
                png = image_preview;
                jpg = image_preview;
                jpeg = image_preview;
                gif = image_preview;
                webp = image_preview;
                svg = image_preview;
              };
          };
        };
        winopts = {
          width = 0.8;
          height = 0.8;
          row = 0.5;
          col = 0.5;
          backdrop = 70;
          preview = { scrollchars = [ "┃" "" ]; };
          on_create = luaRawExpr ''
            return function()
              -- Prevent using tmux navigator bindings while in fzf.
              vim.keymap.set("t", "<c-j>", "<c-j>", { nowait = true, buffer = true })
              vim.keymap.set("t", "<c-k>", "<c-k>", { nowait = true, buffer = true })
              vim.keymap.set("t", "<c-l>", "<c-l>", { nowait = true, buffer = true })
              vim.keymap.set("t", "<c-h>", "<c-h>", { nowait = true, buffer = true })
            end
          '';
        };
        files = {
          cwd_prompt = false;
          actions = {
            "ctrl-h" =
              [ (luaRaw ''require("fzf-lua.actions").toggle_hidden'') ];
          };
        };
        grep = {
          actions = {
            "ctrl-h" =
              [ (luaRaw ''require("fzf-lua.actions").toggle_hidden'') ];
          };
        };
        lsp = {
          symbols = {
            # Color code based on LSP kind.
            symbol_hl = luaRawExpr ''
              return function(s)
                return "BlinkCmpKind" .. s
              end
            '';
            # Remove [] from symbol icon and type.
            symbol_fmt = luaRawExpr ''
              return function(s)
                return s:lower() .. "\t"
              end
            '';
          };
        };
      };
    };
    plugins.which-key.settings.spec = [{
      __unkeyed-1 = "<leader>f";
      group = "+search";
    }];

    # FzfLua keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader><space>";
        action = "<cmd>FzfLua files<cr>";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>FzfLua live_grep<cr>";
        options.desc = "Search Files";
      }
      {
        mode = "n";
        key = "<leader>:";
        action = "<cmd>FzfLua command_history<cr>";
        options.desc = "Command History";
      }
      {
        mode = "n";
        key = "<leader>,";
        action = "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>";
        options.desc = "Switch Buffer";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>";
        options.desc = "Switch Buffer";
      }
      {
        mode = "n";
        key = ''<leader>f"'';
        action = "<cmd>FzfLua registers<cr>";
        options.desc = "Registers";
      }
      {
        mode = "n";
        key = "<leader>fa";
        action = "<cmd>FzfLua autocmds<cr>";
        options.desc = "Auto Commands";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>FzfLua grep_curbuf<cr>";
        options.desc = "Buffer";
      }
      {
        mode = "n";
        key = "<leader>fc";
        action = "<cmd>FzfLua commands<cr>";
        options.desc = "Commands";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd>FzfLua diagnostics_document<cr>";
        options.desc = "Diagnostics (Buffer)";
      }
      {
        mode = "n";
        key = "<leader>fD";
        action = "<cmd>FzfLua diagnostics_workspace<cr>";
        options.desc = "Diagnostics (All)";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>FzfLua git_files<cr>";
        options.desc = "Find Git Files";
      }
      {
        mode = "n";
        key = "<leader>fF";
        action = "<cmd>FzfLua find_files<cr>";
        options.desc = "Find Hidden Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>FzfLua live_grep<cr>";
        options.desc = "Grep";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>FzfLua helptags<cr>";
        options.desc = "Help Pages";
      }
      {
        mode = "n";
        key = "<leader>fH";
        action = "<cmd>FzfLua highlights<cr>";
        options.desc = "Highlight Groups";
      }
      {
        mode = "n";
        key = "<leader>fj";
        action = "<cmd>FzfLua jumps<cr>";
        options.desc = "Jumplist";
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = "<cmd>FzfLua keymaps<cr>";
        options.desc = "Key Maps";
      }
      {
        mode = "n";
        key = "<leader>fl";
        action = "<cmd>FzfLua loclist<cr>";
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>fL";
        action = "<cmd>FzfLua lsp_finder<cr>";
        options.desc = "LSP Finder";
      }
      {
        mode = "n";
        key = "<leader>fM";
        action = "<cmd>FzfLua manpages<cr>";
        options.desc = "Man Pages";
      }
      {
        mode = "n";
        key = "<leader>fm";
        action = "<cmd>FzfLua marks<cr>";
        options.desc = "Marks";
      }
      {
        mode = "n";
        key = "<leader>fq";
        action = "<cmd>FzfLua quickfix<cr>";
        options.desc = "Quickfix List";
      }
      {
        mode = "n";
        key = "<leader>fR";
        action = "<cmd>FzfLua oldfiles<cr>";
        options.desc = "Recent Files";
      }
      {
        mode = "n";
        key = "<leader>fz";
        action = "<cmd>FzfLua resume<cr>";
        options.desc = "FzfLua Resume";
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<cmd>FzfLua lsp_document_symbols<cr>";
        options.desc = "Symbols (Buffer)";
      }
      {
        mode = "n";
        key = "<leader>fS";
        action = "<cmd>FzfLua lsp_live_workspace_symbols<cr>";
        options.desc = "Symbols (All)";
      }
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>FzfLua treesitter<cr>";
        options.desc = "Treesitter";
      }
      {
        mode = "n";
        key = "<leader>fw";
        action = "<cmd>FzfLua grep_cword<cr>";
        options.desc = "Search current word";
      }
      {
        mode = "v";
        key = "<leader>fw";
        action = "<cmd>FzfLua grep_visual<cr>";
        options.desc = "Search current selection";
      }
    ];
  };

  home.packages = with pkgs; [ chafa ];
}
