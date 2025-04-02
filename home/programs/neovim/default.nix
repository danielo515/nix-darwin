# Neovim configuration
{ flake, ... }: {
  imports = [ flake.inputs.nixvim.homeManagerModules.nixvim ./fzf-lua.nix ];

  programs.nixvim = import ./nixvim.nix // { enable = true; };
}
