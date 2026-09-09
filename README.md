# nix-darwin

## Activate on Linux

Only Nix (with flakes) is required. The repo must be cloned to
`~/.config/home-manager`, since the config symlinks live-editable dotfiles from
that path.

```bash
git clone https://github.com/danielo515/nix-darwin ~/.config/home-manager
cd ~/.config/home-manager
nix run home-manager -- switch --flake .#danielo-linux
```

Later updates:

```bash
cd ~/.config/home-manager && git pull && nix run home-manager -- switch --flake .#danielo-linux
```
