#!/usr/bin/env bash
# Bootstrap for any fresh box (Lightning Studio, generic Linux, macOS).
#
# Everything declarative lives in ~/dotfiles/flake.nix + ~/dotfiles/hm/.
# This script only handles the chicken-and-egg parts: get the repo on disk,
# install Nix, then hand off to home-manager.
#
# Usage:
#     bash dotfiles/res/setup.sh [linux|mac]
# Defaults to `linux` on Linux, `mac` on Darwin.

set -euo pipefail

PERSIST_DIR="${PERSIST_DIR:-$HOME}"
DOTFILES="${DOTFILES:-$PERSIST_DIR/dotfiles}"
REPO_URL="https://github.com/macmccallum/dotfiles.git"

log() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }

# 1. Dotfiles on disk
if [ ! -d "$DOTFILES/.git" ]; then
  log "cloning dotfiles into $DOTFILES"
  git clone "$REPO_URL" "$DOTFILES"
else
  log "dotfiles present at $DOTFILES"
fi
# Make ~/dotfiles point at the repo, but only if it isn't already the repo
# itself. (When $DOTFILES == $HOME/dotfiles the previous `ln -sfn` would
# create a self-symlink *inside* the directory.)
if [ "$DOTFILES" != "$HOME/dotfiles" ] && [ ! -e "$HOME/dotfiles" ]; then
  ln -s "$DOTFILES" "$HOME/dotfiles"
fi

# 2. Nix. macOS requires daemon (multi-user) mode; Linux uses single-user.
if [ ! -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] \
   && [ ! -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  case "$(uname)" in
    Darwin)
      log "installing nix (daemon, macOS)"
      curl -L https://nixos.org/nix/install | sh -s -- --daemon
      ;;
    *)
      log "installing nix (single-user)"
      curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
      ;;
  esac
fi
# shellcheck disable=SC1091
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# 3. Pick host profile
PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
  case "$(uname)" in
    Darwin) PROFILE=mac ;;
    Linux)  PROFILE=linux ;;
    *) echo "unsupported OS: $(uname)" >&2; exit 1 ;;
  esac
fi
log "activating home-manager profile: $PROFILE"

# 3b. Heal a corrupted libgit2 tarball cache. On some hosts (e.g. Lightning
#     Studios after a persistence reset) this directory exists but is not a
#     valid git repo, which makes `nix build` fail with libgit2 error 6
#     before evaluation even starts.
for d in "$HOME/.cache/nix/tarball-cache-v2" \
         "${XDG_CACHE_HOME:-}/nix/tarball-cache-v2"; do
  [ -n "$d" ] || continue
  [ -e "$d" ] || continue
  if [ ! -e "$d/HEAD" ] && [ ! -d "$d/.git" ]; then
    log "removing corrupt nix tarball cache: $d"
    rm -rf "$d"
  fi
done

# 4. Build + activate. --impure so `home.{username,homeDirectory}` can read
#    $USER / $HOME (pure flake eval would force per-host hardcoding).
OUT_LINK="$HOME/.cache/home-manager-result"
mkdir -p "$(dirname "$OUT_LINK")"
nix --extra-experimental-features 'nix-command flakes' \
  build --impure --out-link "$OUT_LINK" \
  "$DOTFILES#homeConfigurations.$PROFILE.activationPackage"
"$OUT_LINK/activate"

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  log "done. open a new shell, or: source ~/.nix-profile/etc/profile.d/nix.sh"
elif [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  log "done. open a new shell, or: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
else
  log "done. open a new shell to pick up the Nix environment."
fi
