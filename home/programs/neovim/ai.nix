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
  # what this turn touched, so the review happens in the real, editable buffers
  # rather than in a diff viewer layered on top of them.
  #
  # While a review is pending the touched buffers take a handful of single keys
  # (<Tab>, <CR>, X, ?, q, Q) so the repeated actions cost one keystroke rather
  # than a leader chord. They are scoped to those buffers, shadow-and-restore
  # anything they cover, and drop away the moment you enter insert mode. A
  # lualine segment stays lit throughout, since a gutter that silently changed
  # meaning is worse than no gutter.
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
      local M = { base = nil, changed = {}, added = {}, files = {}, armed = false }

      local keys_group = vim.api.nvim_create_augroup("ClaudeTurnReviewKeys", { clear = true })

      local function git(args)
        local out = vim.fn.systemlist(vim.list_extend({ "git" }, args))
        if vim.v.shell_error ~= 0 then
          return nil
        end
        return out
      end

      local function report_path()
        local out = git({ "rev-parse", "--git-dir" })
        if not out or not out[1] or out[1] == "" then
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
        if not git({ "rev-parse", "--verify", "--quiet", base .. "^{commit}" }) then
          return false
        end
        local root = git({ "rev-parse", "--show-toplevel" })
        root = root and root[1]
        if not root or root == "" then
          return false
        end
        local changed, added, files = {}, {}, {}
        for _, line in ipairs(lines) do
          local kind, file = line:match("^(%a)\t(.+)$")
          if kind then
            local abs = root .. "/" .. file
            if kind == "M" then
              table.insert(changed, file)
            else
              table.insert(added, file)
            end
            table.insert(files, abs)
          end
        end
        M.base, M.changed, M.added, M.files = base, changed, added, files
        return true
      end

      local function clear()
        M.base, M.changed, M.added, M.files = nil, {}, {}, {}
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

      local function refresh_status()
        pcall(function()
          require("lualine").refresh()
        end)
      end

      ---------------------------------------------------------------------
      -- Hunks
      ---------------------------------------------------------------------

      -- Read hunk positions straight from gitsigns rather than driving
      -- nav_hunk(), so "is there a next hunk in this file" is a plain
      -- comparison instead of a guess about where the cursor landed.
      local function hunk_lines(buf)
        local ok, gs = pcall(require, "gitsigns")
        if not ok then
          return {}
        end
        local hunks = gs.get_hunks(buf) or {}
        local lines = {}
        for _, h in ipairs(hunks) do
          table.insert(lines, math.max(h.added.start, 1))
        end
        table.sort(lines)
        return lines
      end

      local function file_index(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        for i, f in ipairs(M.files) do
          if f == name then
            return i
          end
        end
        return nil
      end

      local function jump_to_line(line)
        local last = vim.api.nvim_buf_line_count(0)
        vim.api.nvim_win_set_cursor(0, { math.min(line, last), 0 })
        vim.cmd("normal! zz")
        refresh_status()
      end

      -- gitsigns attaches asynchronously, so a freshly opened file has no hunks
      -- for a few ticks. Retry briefly rather than landing on line 1.
      local function jump_first_hunk(tries)
        tries = tries or 10
        local lines = hunk_lines(0)
        if #lines > 0 then
          jump_to_line(lines[1])
          return
        end
        if tries > 0 then
          vim.defer_fn(function()
            jump_first_hunk(tries - 1)
          end, 40)
        end
      end

      local function open_file(i)
        if #M.files == 0 then
          return false
        end
        i = ((i - 1) % #M.files) + 1
        local target = M.files[i]
        if vim.fn.filereadable(target) == 0 then
          return false
        end
        vim.cmd("edit " .. vim.fn.fnameescape(target))
        jump_first_hunk()
        return true
      end

      ---------------------------------------------------------------------
      -- Review actions
      ---------------------------------------------------------------------

      local function next_hunk()
        local buf = vim.api.nvim_get_current_buf()
        local cur = vim.api.nvim_win_get_cursor(0)[1]
        for _, l in ipairs(hunk_lines(buf)) do
          if l > cur then
            jump_to_line(l)
            return
          end
        end
        local i = file_index(buf)
        if i then
          open_file(i + 1)
        end
      end

      local function prev_hunk()
        local buf = vim.api.nvim_get_current_buf()
        local cur = vim.api.nvim_win_get_cursor(0)[1]
        local target = nil
        for _, l in ipairs(hunk_lines(buf)) do
          if l < cur then
            target = l
          end
        end
        if target then
          jump_to_line(target)
          return
        end
        local i = file_index(buf)
        if i then
          open_file(i - 1)
        end
      end

      -- Keeping is deliberately a no-op that just moves on: the edit is already
      -- on disk, so the only real decision is keep or revert. Staging it would
      -- leave the index half-populated as a side effect of reviewing.
      local function keep_hunk()
        next_hunk()
      end

      -- With the base pointed at the turn snapshot, reset_hunk reverts to what
      -- the file looked like before Claude touched it.
      local function revert_hunk()
        local ok, gs = pcall(require, "gitsigns")
        if not ok then
          return
        end
        gs.reset_hunk()
        -- Claude wrote the change to disk, so undoing it has to reach disk too;
        -- leaving the buffer dirty would make the gutter and the file disagree.
        -- noautocmd keeps conform's format-on-save from reformatting the whole
        -- file in the middle of a review.
        local buf = vim.api.nvim_get_current_buf()
        local function save(tries)
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          if vim.bo[buf].modified then
            vim.api.nvim_buf_call(buf, function()
              pcall(vim.cmd, "silent noautocmd write")
            end)
            pcall(gs.refresh)
            refresh_status()
          elseif tries > 0 then
            -- reset_hunk runs async, so the buffer is not dirty yet on the
            -- first tick after the call returns.
            vim.defer_fn(function()
              save(tries - 1)
            end, 40)
          end
        end
        save(10)
      end

      ---------------------------------------------------------------------
      -- Key hint
      ---------------------------------------------------------------------

      local hint_win = nil

      local KEYS = {
        { "<Tab>", "next hunk", next_hunk },
        { "<S-Tab>", "previous hunk", prev_hunk },
        { "<CR>", "keep, go to next", keep_hunk },
        { "X", "revert this hunk", revert_hunk },
        { "?", "toggle this hint", nil },
        { "q", "pause review", nil },
        { "Q", "finish review", nil },
      }

      local function close_hint()
        if hint_win and vim.api.nvim_win_is_valid(hint_win) then
          vim.api.nvim_win_close(hint_win, true)
        end
        hint_win = nil
      end

      local function toggle_hint()
        if hint_win and vim.api.nvim_win_is_valid(hint_win) then
          close_hint()
          return
        end
        local lines, width = {}, 0
        for _, k in ipairs(KEYS) do
          local line = string.format("  %-8s %s", k[1], k[2])
          width = math.max(width, #line)
          table.insert(lines, line)
        end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        hint_win = vim.api.nvim_open_win(buf, false, {
          relative = "editor",
          anchor = "SE",
          row = vim.o.lines - 2,
          col = vim.o.columns - 2,
          width = width + 2,
          height = #lines,
          style = "minimal",
          border = "rounded",
          title = " Claude review ",
        })
      end

      ---------------------------------------------------------------------
      -- Arming
      ---------------------------------------------------------------------

      local saved_maps = {}

      local function map_buf(buf)
        if saved_maps[buf] then
          return
        end
        saved_maps[buf] = {}
        for _, k in ipairs(KEYS) do
          local lhs = k[1]
          -- Remember any buffer-local map we shadow so exiting review mode
          -- gives the buffer back exactly as it was.
          local prev = vim.fn.maparg(lhs, "n", false, true)
          if prev and prev.buffer == 1 then
            table.insert(saved_maps[buf], prev)
          end
        end
        local function set(lhs, desc, fn)
          vim.keymap.set("n", lhs, fn, { buffer = buf, desc = "Claude review: " .. desc })
        end
        set("<Tab>", "next hunk", next_hunk)
        set("<S-Tab>", "previous hunk", prev_hunk)
        set("<CR>", "keep, go to next", keep_hunk)
        set("X", "revert this hunk", revert_hunk)
        set("?", "toggle hint", toggle_hint)
        set("q", "pause review", function()
          M.pause()
        end)
        set("Q", "finish review", function()
          M.finish()
        end)
      end

      local function unmap_buf(buf)
        local saved = saved_maps[buf]
        if not saved then
          return
        end
        if vim.api.nvim_buf_is_valid(buf) then
          for _, k in ipairs(KEYS) do
            pcall(vim.keymap.del, "n", k[1], { buffer = buf })
          end
          for _, prev in ipairs(saved) do
            pcall(vim.fn.mapset, "n", false, prev)
          end
        end
        saved_maps[buf] = nil
      end

      local function in_review(buf)
        return file_index(buf) ~= nil
      end

      function M.arm()
        if not M.base or #M.files == 0 then
          return
        end
        M.armed = true
        vim.api.nvim_clear_autocmds({ group = keys_group })
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and in_review(buf) then
            map_buf(buf)
          end
        end
        -- Files opened later in the review still need the keys.
        vim.api.nvim_create_autocmd("BufEnter", {
          group = keys_group,
          callback = function(ev)
            if M.armed and in_review(ev.buf) then
              map_buf(ev.buf)
            end
          end,
        })
        -- Editing by hand means you are done being driven by single keys.
        vim.api.nvim_create_autocmd("InsertEnter", {
          group = keys_group,
          callback = function(ev)
            if M.armed and in_review(ev.buf) then
              M.pause()
            end
          end,
        })
        -- The statusline carries the hunk counter, so keep it honest.
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = keys_group,
          callback = function(ev)
            if M.armed and in_review(ev.buf) then
              refresh_status()
            end
          end,
        })
        refresh_status()
      end

      local function disarm()
        M.armed = false
        vim.api.nvim_clear_autocmds({ group = keys_group })
        close_hint()
        for buf in pairs(vim.deepcopy(saved_maps)) do
          unmap_buf(buf)
        end
        refresh_status()
      end

      ---------------------------------------------------------------------
      -- Entry points
      ---------------------------------------------------------------------

      local function apply_base()
        local ok, gs = pcall(require, "gitsigns")
        if ok then
          gs.change_base(M.base, true)
        end
      end

      -- Called over the socket by dotfiles/claude/hooks/turn-review-notify.sh.
      function M.on_turn_end()
        vim.schedule(function()
          if not load() then
            return
          end
          vim.cmd.checktime()
          local msg = { "Claude: " .. summary() }
          local shown = math.min(#M.files, 5)
          for i = 1, shown do
            table.insert(msg, "  " .. M.files[i]:gsub("^.*/", ""))
          end
          if #M.files > shown then
            table.insert(msg, "  … " .. (#M.files - shown) .. " more")
          end
          table.insert(msg, "<Tab> next · <CR> keep · X revert · ? keys")
          vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, { title = "Turn complete" })
          apply_base()
          M.arm()
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
        if not M.armed then
          return "󰚩 " .. summary() .. " · <leader>av"
        end
        local buf = vim.api.nvim_get_current_buf()
        local i = file_index(buf)
        if not i then
          return "󰚩 REVIEW · " .. summary()
        end
        local lines = hunk_lines(buf)
        local cur = vim.api.nvim_win_get_cursor(0)[1]
        local h = 0
        for n, l in ipairs(lines) do
          if l <= cur then
            h = n
          end
        end
        return string.format("󰚩 REVIEW %d/%d · file %d/%d", h, #lines, i, #M.files)
      end

      -- Re-arm after a pause, and jump to the first thing worth looking at.
      function M.open()
        if not M.base then
          vim.notify("No Claude turn to review", vim.log.levels.WARN)
          return
        end
        M.arm()
        if not in_review(vim.api.nvim_get_current_buf()) then
          open_file(1)
        else
          jump_first_hunk()
        end
      end

      -- Stop driving the buffers but keep the review, so coming back is free.
      function M.pause()
        disarm()
      end

      -- Hand the worktree back to normal git semantics once the review is done.
      function M.finish()
        disarm()
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
        vim.notify("Review finished, diffing against index again", vim.log.levels.INFO)
      end

      -- Side-by-side, for when the gutter is not enough. Explicitly opt-in.
      function M.diffview()
        if not M.base then
          vim.notify("No Claude turn to review", vim.log.levels.WARN)
          return
        end
        vim.cmd("DiffviewOpen " .. M.base .. " --untracked-files=true")
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
        M.arm()
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
      options.desc = "Resume review of Claude's changes";
    }
    {
      mode = "n";
      key = "<leader>aV";
      action.__raw = ''function() require("claude_turn_review").finish() end'';
      options.desc = "Finish review (reset git base)";
    }
    {
      mode = "n";
      key = "<leader>aD";
      action.__raw = ''function() require("claude_turn_review").diffview() end'';
      options.desc = "Review in side-by-side diffview";
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
