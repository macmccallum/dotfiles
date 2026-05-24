# dotfiles

Portable CLI development environment. One flake, two host profiles:

| Profile | OS                 | Shell |
|---------|--------------------|-------|
| `linux` | x86_64 Linux       | bash  |
| `mac`   | aarch64 Darwin     | zsh   |

Managed by [home-manager](https://github.com/nix-community/home-manager) with
a light touch: the existing rc files in this repo are dropped into `$HOME`
verbatim, so they continue to work on non-Nix machines too.

## Bootstrap a fresh machine

```sh
curl -fsSL https://raw.githubusercontent.com/macmccallum/dotfiles/main/res/setup.sh | bash
# or, with the repo already cloned:
bash ~/dotfiles/res/setup.sh        # auto-detects linux vs mac
bash ~/dotfiles/res/setup.sh linux  # force a profile
```

The script:

1. Clones this repo to `~/dotfiles` if missing.
2. Installs Nix single-user (`--no-daemon`) if missing. On macOS this needs
   one-time `sudo` to create `/nix` (SIP). Everywhere else is fully rootless.
3. Builds and activates the home-manager profile.

## Re-activate after editing the flake

```sh
bash ~/dotfiles/res/setup.sh
```

Or, equivalently:

```sh
nix --extra-experimental-features 'nix-command flakes' \
  build --impure ~/dotfiles#homeConfigurations.linux.activationPackage \
  --out-link ~/.cache/home-manager-result
~/.cache/home-manager-result/activate
```

`--impure` is required because `home.{username,homeDirectory}` are resolved
from `$USER` / `$HOME` at evaluation time (so the same flake works on any
box / username without per-machine hardcoding). See `running_plan.md` for
the trade-off discussion.

## Layout

```
flake.nix           home-manager flake (entry point)
hm/
  common.nix        shared module: packages + dotfile drops
  linux.nix         linux profile: bash files
  mac.nix           mac profile:   zsh files + .zshrc stub
res/
  flake.nix         project dev shell (`nix develop`)
  setup.sh          bootstrap script
bash/  zsh/         shell rc files (managed by hm/{linux,mac}.nix)
nvim/  tmux/  nix/  config trees (managed by hm/common.nix)
aerospace/ hammerspoon/ qutebrowser/ multipass/ spack/ cobib/
                    macOS / legacy; still stow-managed, not yet migrated
running_plan.md     live working doc for the migration
```

## What home-manager places in `$HOME`

After activation, these are symlinks into the Nix store:

- `~/.bashrc`, `~/.bash_profile`, `~/.bash_config` (linux only)
- `~/.zshrc`, `~/.zsh_config` (mac only)
- `~/.config/nvim/`
- `~/.config/tmux/tmux.conf`
- `~/.config/nix/nix.conf`

And `~/.config/tmux/plugins/tpm/` is cloned once on first activation; tpm
manages plugins from there.

Packages installed into the user profile: `tmux gh stow git curl tig
ripgrep fzf direnv nix-direnv neovim`.

## Dev shell

Project-scoped tools live in `res/flake.nix` and are unrelated to home-manager:

```sh
cd ~/dotfiles/res && nix develop
```
