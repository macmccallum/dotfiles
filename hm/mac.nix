# macOS host profile: zsh + any Mac-only extras.
# GUI tools (aerospace, hammerspoon, qutebrowser) are intentionally deferred.
{ config, pkgs, lib, ... }:

let
  repo = ../.;
in
{
  imports = [ ./common.nix ];

  # zsh rc + the stub that sources it.
  home.file.".zshrc".source      = "${repo}/zsh/.zshrc";
  home.file.".zsh_config".source = "${repo}/zsh/.zsh_config";

  # Mac-only packages go here when we need them. Empty for now.
  # home.packages = with pkgs; [ ... ];
}
