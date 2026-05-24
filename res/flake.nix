{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = (with pkgs; [
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
          ]) ++ [ unstable.neovim ];

          shellHook = ''
            echo "Development environment loaded"
            echo "Available tools: neovim, gh, tmux, stow, tig, git, curl, rg, fzf"
          '';
        };
      }
    );
}
