{
  config,
  ...
}: let
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  home.file = {
    # Stored under a neutral name in the repo so no agent automation picks it
    # up there; the symlink restores the name Claude Code expects.
    ".claude/CLAUDE.md".source = link "${config.dotfiles.path}/claude/global-instructions.md";
    ".claude/settings.json".source = link "${config.dotfiles.path}/claude/settings.json";
    ".claude/statusline-command.sh".source = link "${config.dotfiles.path}/claude/statusline-command.sh";
    # Only this hook is ours; herdr-agent-state.sh is written and updated by
    # herdr's integration, so the hooks directory itself stays unmanaged.
    ".claude/hooks/check-npm.mjs".source = link "${config.dotfiles.path}/claude/hooks/check-npm.mjs";
    # Only this agent is ours; other agents may be user-local, so the agents
    # directory itself stays unmanaged.
    ".claude/agents/effect-log-annotations.md".source = link "${config.dotfiles.path}/claude/agents/effect-log-annotations.md";
    ".agents/.skill-lock.json".source = link "${config.dotfiles.path}/claude/skill-lock.json";
  };
}
