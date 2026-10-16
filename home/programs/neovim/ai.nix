# AI agent integration.
#
# claudecode.nvim talks to the Claude Code CLI over the same WebSocket MCP
# protocol the official VS Code/JetBrains extensions use: the agent sees the
# active buffer, the visual selection, workspace diagnostics, and renders its
# edits as native nvim diffs you accept or reject.
#
# codecompanion.nvim is the in-editor chat/inline-assistant counterpart, driven
# over ACP by the same `claude` binary, for prompts that don't warrant a session.
{
  # claudecode.nvim pulls in nixpkgs' claude-code by default, which would shadow
  # the newer natively-installed CLI on nvim's PATH.
  dependencies.claude-code.enable = false;

  # 'autoread' only reloads when something asks nvim to stat the file. Poke it
  # on the events that mean "the user came back to look", so edits written by an
  # agent running outside this nvim show up without an explicit :e!.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
      group = vim.api.nvim_create_augroup("AgentFileReload", { clear = true }),
      callback = function()
        if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then
          vim.cmd.checktime()
        end
      end,
    })
  '';

  plugins = {
    # Terminal/picker primitives claudecode.nvim uses for its split.
    snacks = {
      enable = true;
      settings = {
        terminal.enabled = true;
        input.enabled = true;
      };
    };

    claudecode = {
      enable = true;
      settings = {
        terminal = {
          split_side = "right";
          split_width_percentage = 0.35;
          provider = "snacks";
        };
        diff_opts = {
          layout = "vertical";
          open_in_new_tab = false;
        };
      };
    };

    codecompanion = {
      enable = true;
      settings = {
        adapters.acp.claude_code.__raw = ''
          function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = { CLAUDE_CODE_OAUTH_TOKEN = "cmd:echo $CLAUDE_CODE_OAUTH_TOKEN" },
            })
          end
        '';
        strategies = {
          chat.adapter = "claude_code";
          inline.adapter = "claude_code";
        };
        display.diff.provider = "default";
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>ac";
      action = "<cmd>ClaudeCode<CR>";
      options.desc = "Toggle Claude Code";
    }
    {
      mode = "n";
      key = "<leader>af";
      action = "<cmd>ClaudeCodeFocus<CR>";
      options.desc = "Focus Claude Code";
    }
    {
      mode = "n";
      key = "<leader>ar";
      action = "<cmd>ClaudeCode --resume<CR>";
      options.desc = "Resume Claude Code session";
    }
    {
      mode = "n";
      key = "<leader>aC";
      action = "<cmd>ClaudeCode --continue<CR>";
      options.desc = "Continue last Claude Code session";
    }
    {
      mode = "n";
      key = "<leader>am";
      action = "<cmd>ClaudeCodeSelectModel<CR>";
      options.desc = "Select Claude model";
    }
    {
      mode = "n";
      key = "<leader>ab";
      action = "<cmd>ClaudeCodeAdd %<CR>";
      options.desc = "Add current buffer to Claude context";
    }
    {
      mode = "v";
      key = "<leader>as";
      action = "<cmd>ClaudeCodeSend<CR>";
      options.desc = "Send selection to Claude";
    }
    # Diff review (active while Claude proposes an edit).
    {
      mode = "n";
      key = "<leader>aa";
      action = "<cmd>ClaudeCodeDiffAccept<CR>";
      options.desc = "Accept Claude diff";
    }
    {
      mode = "n";
      key = "<leader>ad";
      action = "<cmd>ClaudeCodeDiffDeny<CR>";
      options.desc = "Deny Claude diff";
    }
    # CodeCompanion
    {
      mode = "n";
      key = "<leader>at";
      action = "<cmd>CodeCompanionChat Toggle<CR>";
      options.desc = "Toggle CodeCompanion chat";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ai";
      action = ":CodeCompanion<CR>";
      options.desc = "CodeCompanion inline prompt";
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>ap";
      action = "<cmd>CodeCompanionActions<CR>";
      options.desc = "CodeCompanion actions palette";
    }
  ];
}
