# Neovim configuration
{ flake, ... }: {
  imports = [ flake.inputs.nixvim.homeModules.nixvim ./fzf-lua.nix ];

  programs.nixvim = import ./nixvim.nix // { enable = true; };
}
