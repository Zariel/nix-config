{ config, lib, pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./packages.nix
  ];
}