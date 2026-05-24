# Running Plan: Portable Nix / home-manager Config

Live working document for the migration from stow + setup.sh to home-manager.
Updated as we go. Strike-through = done, plain = pending, **bold** = in progress.

## Goal

One flake at `~/dotfiles/flake.nix` that produces working CLI environments on:

- macOS (Apple Silicon, zsh) — host profile `mac`
- Linux (x86_64, bash) — host profile `linux` (covers Lightning Studio + any
  generic Linux server)

Light-touch home-manager: HM drops the existing rc files into `$HOME`
verbatim. Shell configs remain hand-rolled and continue to work on non-Nix
machines. Stow stays functional in parallel during migration.

## Decisions locked in

- Two generic host profiles (`mac`, `linux`), not per-machine.
- Nix install mode is OS-dependent: **single-user (`--no-daemon`)** on Linux
  (fully rootless), **multi-user (`--daemon`)** on macOS. The official
  installer dropped single-user support on Darwin, so macOS gets a
  `nix-daemon` via `launchd` with a one-time `sudo`.
- Keep `res/flake.nix` dev shell as-is; orthogonal concern.
- macOS GUI tools (aerospace, hammerspoon, qutebrowser) deferred to a later
  session.
- pi CLI and juliaup deferred — packaged separately later.

## File layout (target)

```
~/dotfiles/
  flake.nix              NEW   home-manager flake
  flake.lock             NEW   generated
  hm/
    common.nix           NEW   shared packages + dotfile drops + nix.conf
    linux.nix            NEW   bash, Linux-only bits
    mac.nix              NEW   zsh, Mac-only bits
  zsh/.zshrc             NEW   minimal stub sourcing .zsh_config
  res/setup.sh           MOD   shrunk to bootstrap + `nix run home-manager`
  dotfiles               DEL   self-symlink, leftover from old setup.sh
```

## Steps

1. [x] Remove self-symlink `~/dotfiles/dotfiles`.
2. [x] Add minimal `zsh/.zshrc` stub.
3. [x] Write `hm/common.nix` (packages, nvim/tmux/nix.conf drops, tpm clone
       activation).
4. [x] Write `hm/linux.nix` (bash files).
5. [x] Write `hm/mac.nix` (zsh files + stub).
6. [x] Write `flake.nix` (inputs, `homeConfigurations.{mac,linux}`).
7. [x] `nix flake lock` generated `flake.lock`.
8. [x] Build activation package on Lightning (`linux` profile). Required
       `--impure` because `home.{username,homeDirectory}` use
       `builtins.getEnv`.
9. [x] Real activate. Verified: `~/.bashrc`, `~/.bash_profile`,
       `~/.bash_config`, `~/.config/nvim`, `~/.config/tmux/tmux.conf` all
       point at HM-managed store paths. `tpm` auto-cloned. HM packages
       (nvim, tmux, rg, fzf, gh, stow, tig, direnv) on PATH.
10. [x] `res/setup.sh` rewritten: clones repo, installs Nix if missing,
        picks profile from `uname`, runs
        `nix build --impure ...#homeConfigurations.<profile>.activationPackage`
        then `./result/activate`. End-to-end re-run on Lightning works
        (created generation 2).
11. [x] Fix Mac bootstrap: `--no-daemon` is rejected by the official
        installer on Darwin. `setup.sh` now branches on `uname` and uses
        `--daemon` on macOS, `--no-daemon` on Linux, and sources the
        appropriate profile script (`nix.sh` vs `nix-daemon.sh`).
12. [ ] Commit. Push. Test on Mac (you, later).

## Gotchas encountered (for future-you)

- **Pure flake eval kills `builtins.getEnv`.** `home.username` /
  `home.homeDirectory` resolve to `""` and HM rejects them. Fix: pass
  `--impure` at build time. `nix run home-manager -- switch --flake ...`
  re-evaluates internally and drops the flag, so the workaround there is
  to `nix build --impure ... && ./result/activate` (what setup.sh does).
- **First-time activation conflicts.** Existing stow symlinks at
  `~/.config/{nvim,tmux}` and a plain `~/.bashrc` block HM. Either remove
  them manually first, or pass `-b backup` to the standalone
  `home-manager switch` (the `./result/activate` route honors
  `HOME_MANAGER_BACKUP_EXT` only for some checks). In this migration we
  removed/moved manually.
- **Broken nix-env manifest from earlier `store = ...` experiment.** The
  user profile pointed at a `manifest.nix` whose store path never existed.
  `nix-env -q` errored; HM's `installPackages` errored. Fix: delete
  `~/.local/state/nix/profiles/profile{,-1-link}` and re-activate (HM
  creates a fresh generation). Make sure `nix-build` is on PATH from an
  absolute store path before removing the profile, since the profile *is*
  what puts `nix-build` on PATH normally.

## Out of scope (next sessions)

- Package `pi` CLI as a flake output (or `home.activation` install).
- Decide: `pkgs.juliaup` vs pinned `pkgs.julia`. Wire `JULIA_DEPOT_PATH` to
  the persistent volume on Lightning only.
- Migrate macOS GUI tools (aerospace, hammerspoon, qutebrowser).
- Decide whether to retire `spack/` and `multipass/`.
- Optionally: nix-darwin for Mac system-level settings.
- Optionally: replace `xdg.configFile` drops with `programs.tmux`,
  `programs.neovim`, `programs.bash`, `programs.zsh` modules (Option B,
  per-block, opt-in).

## Open questions to revisit

- Should `nix.conf` in the repo be the source of truth, or should HM generate
  it via `nix.settings`? (Currently: source of truth = repo file.)
- tpm plugin install: rely on `prefix + I` after first launch, or have HM
  pre-install plugins via an activation script that runs
  `~/.config/tmux/plugins/tpm/bin/install_plugins`?
- Determinate Systems installer vs official installer for the bootstrap line.
  (Currently: official; `--no-daemon` on Linux, `--daemon` on macOS.)

## Test matrix

| Host           | Profile | Shell | Status     |
|----------------|---------|-------|------------|
| Lightning Std. | linux   | bash  | **passing** (gen 2) |
| Mac (M-series) | mac     | zsh   | not tested (daemon-mode install) |
| Generic Linux  | linux   | bash  | not tested |
