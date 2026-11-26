# Neovim configuration
{ flake, ... }: let
  # :Reload exits with 75 when started through this function; reopening through the
  # wrapper on PATH picks up a rebuilt Neovim, its plugins and its tools, unlike :restart.
  reloadLoop = ''
    nvim() {
      local session="''${XDG_STATE_HOME:-$HOME/.local/state}/nvim/reload-session.vim" code
      command nvim --cmd 'let g:reload_loop = 1' "$@"; code=$?
      while [ "$code" -eq 75 ]; do
        command nvim --cmd 'let g:reload_loop = 1' -S "$session"; code=$?
      done
      return "$code"
    }
  '';
in {
  imports = [ flake.inputs.nixvim.homeModules.nixvim ./fzf-lua.nix ];

  programs.nixvim = import ./nixvim.nix // { enable = true; };

  programs.zsh.initContent = reloadLoop;
  programs.bash.initExtra = reloadLoop;
}
