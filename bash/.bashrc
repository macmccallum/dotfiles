export GH_TOKEN=$(cat /etc/github-token 2>/dev/null)

# Source custom bash config
if [ -f ~/.bash_config ]; then
  . ~/.bash_config
fi

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
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
