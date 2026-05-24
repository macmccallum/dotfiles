# Shared home-manager module: packages, dotfile drops, nix.conf.
# Imported by both `linux` and `mac` host profiles.
#
# Convention: light-touch. We symlink existing rc files from the repo into
# $HOME via `home.file` / `xdg.configFile`. Shell config stays hand-rolled
# and portable to non-Nix machines.

{ config, pkgs, lib, ... }:

let
  # Path to the dotfiles repo root, relative to this file.
  repo = ../.;
in
{
  # --- packages ----------------------------------------------------------
  # Mirrors the dev-shell in res/flake.nix. Add sparingly.
  home.packages = with pkgs; [
    tmux
    gh
    stow
    git
    curl
    tig
    ripgrep
    fzf
    direnv
    nix-direnv
    neovim
  ];

  # --- dotfile drops -----------------------------------------------------
  # nvim: drop the whole config tree. lazy.nvim self-bootstraps on launch.
  xdg.configFile."nvim".source = "${repo}/nvim/.config/nvim";

  # tmux: only the conf file. Plugin dir (tpm + installed plugins) stays
  # mutable under ~/.config/tmux/plugins/ so tpm can manage it.
  xdg.configFile."tmux/tmux.conf".source =
    "${repo}/tmux/.config/tmux/tmux.conf";

  # nix.conf: source of truth in repo.
  xdg.configFile."nix/nix.conf".source = "${repo}/nix/.config/nix/nix.conf";

  # --- tpm clone (one-time, idempotent) ----------------------------------
  # HM-managed tmux.conf expects tpm at ~/.config/tmux/plugins/tpm. We clone
  # it once; after that, `prefix + I` inside tmux installs the rest.
  home.activation.installTpm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR/.git" ]; then
      run ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi
  '';

  # --- standard HM plumbing ----------------------------------------------
  programs.home-manager.enable = true;
  home.stateVersion = "24.11"; # do not bump casually; see HM docs.
}
