export GH_TOKEN=$(cat /etc/github-token 2>/dev/null)

# Source custom bash config
if [ -f ~/.bash_config ]; then
  . ~/.bash_config
fi

# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Direnv (auto-loads nix devShell in project directories)
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/masonmccallum/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/masonmccallum/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac
# Tab completion for juliaup and julia channel selection
[ -f "/home/masonmccallum/.julia/juliaup/completions/bash.sh" ] && source "/home/masonmccallum/.julia/juliaup/completions/bash.sh"

# <<< juliaup initialize <<<

# Pi
export PATH="/home/masonmccallum/.local/share/pi-node/node-v22.22.3-linux-x64/bin:$PATH"
