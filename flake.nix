{
  description = "Portable CLI home-manager config (macOS + Linux).";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkHome = system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            module
            {
              # Resolved at activation time from $USER / $HOME, so the same
              # config works for any username on any box.
              home.username = builtins.getEnv "USER";
              home.homeDirectory = builtins.getEnv "HOME";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        linux = mkHome "x86_64-linux" ./hm/linux.nix;
        mac   = mkHome "aarch64-darwin" ./hm/mac.nix;
      };
    };
}
