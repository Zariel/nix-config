{ config, lib, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./packages.nix
    ./xdg.nix
  ];

  # Default home-manager settings
  programs.home-manager.enable = true;
  
  # Nicely reload system units when changing configs (Linux only)
  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";
}