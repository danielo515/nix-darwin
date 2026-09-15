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
  #
  # The rest is the post-turn review flow: Claude runs unattended in auto mode
  # and writes straight to disk, then the Stop hook calls on_turn_end() here.
  # Pointing gitsigns at the turn's baseline commit makes the gutter show only
  # what this turn touched, which turns the existing hunk mappings into
  # reject (<localleader>hr) and approve (<localleader>hs).
  extraConfigLua = ''
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
      group = vim.api.nvim_create_augroup("AgentFileReload", { clear = true }),
      callback = function()
        if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then
          vim.cmd.checktime()
        end
      end,
    })

    package.preload["claude_turn_review"] = function()
      local M = { base = nil }

      -- Called over the socket by dotfiles/claude/hooks/turn-review-notify.sh.
      function M.on_turn_end(base, changed, added)
        M.base = base
        vim.schedule(function()
          vim.cmd.checktime()
          local ok, gs = pcall(require, "gitsigns")
          if ok then
            gs.change_base(base, true)
          end
          local parts = {}
          if changed > 0 then
            table.insert(parts, changed .. " changed")
          end
          if added > 0 then
            table.insert(parts, added .. " new")
          end
          vim.notify(
            "Claude: " .. table.concat(parts, ", ") .. "  ·  <leader>av to review",
            vim.log.levels.INFO,
            { title = "Turn complete" }
          )
        end)
        return 0
      end

      function M.open()
        if not M.base then
          vim.notify("No Claude turn to review", vim.log.levels.WARN)
          return
        end
        -- Untracked files are absent from the baseline commit, so ask diffview
        -- to list them alongside the tracked diff.
        vim.cmd("DiffviewOpen " .. M.base .. " --untracked-files=true")
      end

      -- Hand the worktree back to normal git semantics once the review is done.
      function M.finish()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.reset_base(true)
        end
        pcall(vim.cmd, "DiffviewClose")
        M.base = nil
        vim.notify("Review closed, diffing against index again", vim.log.levels.INFO)
      end

      return M
    end

    -- Deterministic per-cwd socket so the Stop hook can find this instance.
    -- Fixed path rather than $TMPDIR, which differs between nvim and the hook.
    do
      local dir = "/tmp/nvim-claude-review-" .. vim.uv.getuid()
      vim.fn.mkdir(dir, "p")
      local sock = dir .. "/" .. vim.fn.sha256(vim.uv.cwd()):sub(1, 16) .. ".sock"
      pcall(vim.fn.delete, sock)
      pcall(vim.fn.serverstart, sock)
    end
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

    # Review pane for the post-turn diff: file list plus side-by-side.
    diffview.enable = true;

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
    # Post-turn review
    {
      mode = "n";
      key = "<leader>av";
      action.__raw = ''function() require("claude_turn_review").open() end'';
      options.desc = "Review Claude's changes this turn";
    }
    {
      mode = "n";
      key = "<leader>aV";
      action.__raw = ''function() require("claude_turn_review").finish() end'';
      options.desc = "Finish review (reset git base)";
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
