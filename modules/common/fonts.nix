# Common font configuration
{ pkgs, ... }: {
  fonts = {
    # fontDir.enable is no longer needed in newer nix-darwin versions
    packages = with pkgs; [
      # Use the new nerd-fonts namespace
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      nerd-fonts.iosevka
      fira-code
      jetbrains-mono
      material-design-icons
    ];
  };
}
