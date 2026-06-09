# dotfiles

Portable CLI environment managed by [home-manager](https://github.com/nix-community/home-manager).
Two profiles: `linux` (x86_64, bash) and `mac` (aarch64, zsh).

## Bootstrap

```sh
curl -fsSL https://raw.githubusercontent.com/macmccallum/dotfiles/main/res/setup.sh | bash
bash ~/dotfiles/res/setup.sh        # re-activate, or force a profile:
bash ~/dotfiles/res/setup.sh linux
```

Clones the repo, installs Nix if missing (daemon on macOS, single-user on Linux), builds and
activates the profile. `--impure` lets `home.username`/`home.homeDirectory` resolve from env.

## Layout

```
flake.nix           entry point
hm/common.nix       shared packages + dotfile drops
hm/linux.nix        bash files
hm/mac.nix          zsh files
res/setup.sh        bootstrap
bash/  zsh/         shell rc files
nvim/  tmux/  nix/  config trees
```

## What gets linked into $HOME

- `~/.bashrc`, `~/.bash_profile`, `~/.bash_config` (linux)
- `~/.zshrc`, `~/.zsh_config` (mac)
- `~/.config/nvim/`, `~/.config/tmux/tmux.conf`, `~/.config/nix/nix.conf`

Packages: `tmux gh stow git curl tig ripgrep fzf direnv nix-direnv neovim`

## Dev shell

```sh
cd ~/dotfiles/res && nix develop
```
