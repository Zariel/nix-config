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
    zstd
    gzip

    # System tools
    htop
    lsof

    # Nix tools
    nix-tree

    # 1Password CLI (GUI will be installed via Homebrew)
    _1password-cli
  ];
}
