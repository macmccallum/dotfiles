# Minimal .zshrc stub.
# Real config lives in ~/.zsh_config (kept portable / non-Nix).
[ -f "$HOME/.zsh_config" ] && source "$HOME/.zsh_config"

export PATH="$HOME/.local/bin:$PATH"
