{
  config,
  lib,
  pkgs,
  ...
}:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    curl
    wget

    # System tools
    htop
    lsof

    # Nix tools
    nix-tree
  ];
}
