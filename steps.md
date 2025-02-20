# Manual steps list

This is the list of steps that I had to run manually to get to a working configuration.
This is just a reference recipe, the idea is to remove from here and make it all automatic

## Install nix using determinate systems

This step is unavoidable

## Install nix-darwin

I had to install nix-darwin manually by following their steps.
This was before I had a repository for my nix-darwin config.
In the future this step will be documented in the root readme with a clone
command directly pointed at the right place, hopefully

## install homebrew

Required by home-manager to handle brew packages

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## run nix-darwin installation

```bash
darwin-rebuild switch
```

## Start VSCode and login

unavoidable

## Start raycast and login

unavoidable

## Start chrome and login

1. login in the bitwarden extension
2.configure sync for my profiles (personal and work)

## Login into atuin

```bash
atuin login -u <username>
```

Will ask for the key, or password, it's on bitwarden
