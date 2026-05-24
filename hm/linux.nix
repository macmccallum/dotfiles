# Linux host profile: bash + any Linux-only extras.
{ config, pkgs, lib, ... }:

let
  repo = ../.;
in
{
  imports = [ ./common.nix ];

  # Bash rc files dropped verbatim from the repo.
  home.file.".bashrc".source       = "${repo}/bash/.bashrc";
  home.file.".bash_profile".source = "${repo}/bash/.bash_profile";
  home.file.".bash_config".source  = "${repo}/bash/.bash_config";

  # Linux-only packages go here when we need them. Empty for now.
  # home.packages = with pkgs; [ ... ];
}
