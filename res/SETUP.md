# Remote Machine Setup

## Overview
Bootstrap a remote machine with nix, clone dotfiles, and configure neovim and tmux.

## Steps

### Install Nix
```bash
curl -L https://nixos.org/nix/install | sh
source $HOME/.nix-profile/etc/profile.d/nix.sh
```

### clone Dotfiles Repository
```bash
git clone https://github.com/macmccallum/dotfiles.git ~/dotfiles
```

### 3. Enter Nix Development Environment
```bash
cd ~/dotfiles/res
nix flake update
nix develop
```

This will install:
- tmux
- neovim
- juliaup
- gh (GitHub CLI)
- stow
- git
- curl
- tig

### 4. Install Claude CLI
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### 5. Stow Neovim and Tmux Configurations
```bash
cd ~/dotfiles
stow neovim tmux nix
```

## Notes
- The flake.nix in `~/dotfiles/res/` declares all development tools
- `stow` creates symlinks from `~/dotfiles/` to your home directory
- To exit the nix environment: `exit` or `Ctrl+D`
- To re-enter the environment later: `cd ~/dotfiles/res && nix develop`
