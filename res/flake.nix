{
  description = "Development environment with Claude CLI, tmux, neovim, juliaup, and dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            claude-cli
            tmux
            neovim
            juliaup
            gh
            stow
            git
            curl
          ];

          shellHook = ''
            echo "Development environment loaded"
            echo "Available tools: claude-cli, tmux, neovim, juliaup, gh, stow"
          '';
        };
      }
    );
}
