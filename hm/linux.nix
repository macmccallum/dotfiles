# Linux host profile: bash + any Linux-only extras.
{ config, pkgs, lib, ... }:

let
  repo = ../.;
in
{
  imports = [ ./common.nix ];

  # Bash rc files dropped verbatim from the repo.
  # force = true lets Home Manager overwrite any pre-existing files at these
  # paths instead of aborting with a "would be clobbered" error.
  home.file.".bashrc"       = { source = "${repo}/bash/.bashrc";       force = true; };
  home.file.".bash_profile" = { source = "${repo}/bash/.bash_profile"; force = true; };
  home.file.".bash_config"  = { source = "${repo}/bash/.bash_config";  force = true; };

  # Linux-only packages go here when we need them. Empty for now.
  # home.packages = with pkgs; [ ... ];
}
