{
  description = "Development environment";

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
            neovim
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
          ];

          shellHook = ''
            echo "Development environment loaded"
            echo "Available tools: neovim, gh, tmux, stow, tig, git, curl, rg, fzf"
          '';
        };
      }
    );
}
