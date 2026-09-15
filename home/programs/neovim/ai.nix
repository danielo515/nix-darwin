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
  # what this turn touched, so <leader>ak walks the hunks and <leader>ax reverts
  # one. A lualine segment stays lit for as long as the gutter means that, since
  # a gutter that silently changed meaning is worse than no gutter.
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
      local M = { base = nil, changed = {}, added = {} }

      local function report_path()
        local out = vim.fn.systemlist({ "git", "rev-parse", "--git-dir" })
        if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
          return nil
        end
        local git_dir = out[1]
        if not git_dir:match("^/") then
          git_dir = vim.uv.cwd() .. "/" .. git_dir
        end
        return git_dir .. "/claude-turn-review/last.report"
      end

      -- The hook writes the baseline and file list here; see
      -- dotfiles/claude/hooks/turn-review-notify.sh for the format.
      local function load()
        local path = report_path()
        if not path or vim.fn.filereadable(path) == 0 then
          return false
        end
        local lines = vim.fn.readfile(path)
        local base = table.remove(lines, 1)
        if not base or base == "" then
          return false
        end
        -- `git stash create` leaves the baseline unreferenced, so gc can prune
        -- it out from under a stale report.
        vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", base .. "^{commit}" })
        if vim.v.shell_error ~= 0 then
          return false
        end
        local changed, added = {}, {}
        for _, line in ipairs(lines) do
          local kind, file = line:match("^(%a)\t(.+)$")
          if kind == "M" then
            table.insert(changed, file)
          elseif kind == "A" then
            table.insert(added, file)
          end
        end
        M.base, M.changed, M.added = base, changed, added
        return true
      end

      local function clear()
        M.base, M.changed, M.added = nil, {}, {}
      end

      local function summary()
        local parts = {}
        if #M.changed > 0 then
          table.insert(parts, #M.changed .. " changed")
        end
        if #M.added > 0 then
          table.insert(parts, #M.added .. " new")
        end
        return table.concat(parts, ", ")
      end

      local MAX_LISTED = 5

      local function file_lines()
        local all = {}
        for _, f in ipairs(M.changed) do
          table.insert(all, "~ " .. f)
        end
        for _, f in ipairs(M.added) do
          table.insert(all, "+ " .. f)
        end
        local out = {}
        for i = 1, math.min(#all, MAX_LISTED) do
          table.insert(out, "  " .. all[i])
        end
        if #all > MAX_LISTED then
          table.insert(out, "  … " .. (#all - MAX_LISTED) .. " more")
        end
        return out
      end

      local function apply_base()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.change_base(M.base, true)
        end
      end

      -- The lualine segment is the only persistent trace that the gutter is
      -- pointed at a turn baseline rather than the index, so keep it in step.
      local function refresh_status()
        pcall(function()
          require("lualine").refresh()
        end)
      end

      -- Called over the socket by dotfiles/claude/hooks/turn-review-notify.sh.
      function M.on_turn_end()
        vim.schedule(function()
          if not load() then
            return
          end
          vim.cmd.checktime()
          -- Notify before re-basing gitsigns: change_base rescans every attached
          -- buffer, which is slow enough to visibly delay the toast behind it.
          local msg = { "Claude: " .. summary() }
          vim.list_extend(msg, file_lines())
          table.insert(msg, "<leader>av review  ·  <leader>aV finish")
          vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, { title = "Turn complete" })
          apply_base()
          refresh_status()
        end)
        return 0
      end

      function M.active()
        return M.base ~= nil
      end

      function M.status()
        if not M.base then
          return ""
        end
        return "󰚩 " .. summary()
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

      -- Keeping a hunk is deliberately a no-op that just moves on: the edit is
      -- already on disk, so the only real decision is keep or revert. Staging
      -- it would leave the index half-populated as a side effect of reviewing.
      function M.keep()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.nav_hunk("next")
        end
      end

      -- With the base pointed at the turn snapshot, reset_hunk reverts to what
      -- the file looked like before Claude touched it.
      function M.reject()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.reset_hunk()
        end
      end

      -- Hand the worktree back to normal git semantics once the review is done.
      function M.finish()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.reset_base(true)
        end
        pcall(vim.cmd, "DiffviewClose")
        clear()
        local path = report_path()
        if path then
          pcall(vim.fn.delete, path)
        end
        refresh_status()
        vim.notify("Review closed, diffing against index again", vim.log.levels.INFO)
      end

      -- A review outlives the nvim that received it. On startup, pick the
      -- pending one back up, but drop it if the worktree already matches the
      -- baseline again, which means it was dealt with elsewhere.
      function M.restore()
        if not load() then
          return
        end
        vim.fn.system({ "git", "diff", "--quiet", M.base })
        if vim.v.shell_error == 0 and #M.added == 0 then
          clear()
          return
        end
        apply_base()
        refresh_status()
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

      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("ClaudeTurnReview", { clear = true }),
        callback = function()
          require("claude_turn_review").restore()
        end,
      })
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
    {
      mode = "n";
      key = "<leader>ak";
      action.__raw = ''function() require("claude_turn_review").keep() end'';
      options.desc = "Keep hunk, go to next";
    }
    {
      mode = "n";
      key = "<leader>ax";
      action.__raw = ''function() require("claude_turn_review").reject() end'';
      options.desc = "Reject hunk (revert to turn baseline)";
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
