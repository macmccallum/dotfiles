#!/usr/bin/env bash
set -euo pipefail

# Install Nix
curl -L https://nixos.org/nix/install | sh
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Clone dotfiles repository
git clone https://github.com/macmccallum/dotfiles.git ~/dotfiles

# Enter Nix development environment and install tools
cd ~/dotfiles/res
nix flake update
nix develop --command true

# Install Claude CLI
#curl -fsSL https://claude.ai/install.sh | bash

# Install PI
curl -fsSL https://pi.dev/install.sh | sh
export PATH="$HOME/.local/share/pi-node/current/bin:$PATH"

# Install juliaup
curl -fsSL https://install.julialang.org | sh -s -- --yes
export PATH="$HOME/.juliaup/bin:$PATH"

# Stow neovim, tmux, and nix configurations
cd ~/dotfiles
stow neovim tmux nix
