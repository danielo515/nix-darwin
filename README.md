# nix-darwin

## Activate on Linux

Only Nix (with flakes) is required.

One-liner: clones the repo and activates the home-manager configuration.

```bash
nix run github:danielo515/nix-darwin -- ~/.config/home-manager
```

Manual, if the repo is already cloned to `~/.config/home-manager` (the config
symlinks live-editable dotfiles from that path):

```bash
cd ~/.config/home-manager
nix run home-manager -- switch --flake .#danielo-linux
```

Later updates:

```bash
cd ~/.config/home-manager && git pull && nix run home-manager -- switch --flake .#danielo-linux
```
