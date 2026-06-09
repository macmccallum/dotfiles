#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-${PERSIST_DIR:-$HOME}/dotfiles}"
REPO_URL="https://github.com/macmccallum/dotfiles.git"

log() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }

src_nix() {
  if   [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  else
    return 1
  fi
}

if [ ! -d "$DOTFILES/.git" ]; then
  log "cloning dotfiles → $DOTFILES"
  git clone "$REPO_URL" "$DOTFILES"
fi
[ "$DOTFILES" != "$HOME/dotfiles" ] && [ ! -e "$HOME/dotfiles" ] && ln -s "$DOTFILES" "$HOME/dotfiles"

if ! src_nix; then
  case "$(uname)" in
    Darwin) log "installing nix (daemon)";      curl -L https://nixos.org/nix/install | sh -s -- --daemon ;;
    *)      log "installing nix (single-user)"; curl -L https://nixos.org/nix/install | sh -s -- --no-daemon ;;
  esac
  src_nix
fi

for d in "$HOME/.cache/nix/tarball-cache-v2" "${XDG_CACHE_HOME:+$XDG_CACHE_HOME/nix/tarball-cache-v2}"; do
  [ -n "$d" ] && [ -e "$d" ] && [ ! -e "$d/HEAD" ] && [ ! -d "$d/.git" ] && { log "removing corrupt cache: $d"; rm -rf "$d"; }
done

case "${1:-$(uname)}" in
  mac|Darwin)  PROFILE=mac ;;
  linux|Linux) PROFILE=linux ;;
  *) echo "unsupported: ${1:-$(uname)}" >&2; exit 1 ;;
esac

OUT_LINK="$HOME/.cache/home-manager-result"
mkdir -p "$HOME/.cache"
nix --extra-experimental-features 'nix-command flakes' \
  build --impure --out-link "$OUT_LINK" \
  "$DOTFILES#homeConfigurations.$PROFILE.activationPackage"
"$OUT_LINK/activate"

log "done. open a new shell to pick up the Nix environment."
