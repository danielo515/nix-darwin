{config, ...}: let
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  home.file = {
    # Stored under a neutral name in the repo so no agent automation picks it
    # up there; the symlink restores the name Claude Code expects.
    ".claude/CLAUDE.md".source = link /etc/nix-darwin/dotfiles/claude/global-instructions.md;
    ".claude/settings.json".source = link /etc/nix-darwin/dotfiles/claude/settings.json;
    ".claude/statusline-command.sh".source = link /etc/nix-darwin/dotfiles/claude/statusline-command.sh;
    # Only this hook is ours; herdr-agent-state.sh is written and updated by
    # herdr's integration, so the hooks directory itself stays unmanaged.
    ".claude/hooks/check-npm.mjs".source = link /etc/nix-darwin/dotfiles/claude/hooks/check-npm.mjs;
    ".agents/.skill-lock.json".source = link /etc/nix-darwin/dotfiles/claude/skill-lock.json;
  };
}
