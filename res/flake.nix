{
  description = "Development environment with Claude CLI, tmux, neovim, and dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
            tmux
            neovim
            gh
            stow
            git
            curl
            tig
          ];

          shellHook = ''
            echo "Development environment loaded"
            echo "Available tools: claude-cli, tmux, neovim, gh, stow"
          '';
        };
      }
    );
}
