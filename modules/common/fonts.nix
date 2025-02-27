# Common font configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    # fontDir.enable is no longer needed in newer nix-darwin versions
    packages = with pkgs; [
      # Use the new nerd-fonts namespace
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      fira-code
      jetbrains-mono
    ];
  };
}
