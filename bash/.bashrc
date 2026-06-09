export GH_TOKEN=$(cat /etc/github-token 2>/dev/null)

[ -f ~/.bash_config ] && . ~/.bash_config
[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

[ -d "$HOME/.juliaup/bin" ] && export PATH="$HOME/.juliaup/bin:$PATH"
[ -f "$HOME/.julia/juliaup/completions/bash.sh" ] && source "$HOME/.julia/juliaup/completions/bash.sh"
export PATH="$HOME/.local/share/pi-node/node-v22.22.3-linux-x64/bin:$PATH"
