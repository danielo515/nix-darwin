# nix-darwin

## Activate on Linux

Only Nix (with flakes) is required.

One-liner: clones the repo to `~/.config/home-manager` and activates the
home-manager configuration (x86_64 and aarch64).

```bash
nix run github:danielo515/nix-darwin
```

Manual, if the repo is already cloned to `~/.config/home-manager` (the config
symlinks live-editable dotfiles from that path). Use `danielo-linux-arm` on
aarch64:

```bash
cd ~/.config/home-manager
nix run home-manager -- switch --flake .#danielo-linux
```

Later updates:

```bash
cd ~/.config/home-manager && git pull && nix run home-manager -- switch --flake .#danielo-linux
```
