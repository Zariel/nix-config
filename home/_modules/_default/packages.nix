{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    tree
    ripgrep
    fd
    bat
    eza
    zoxide
    fzf
    perl

    # Development tools
    jq
    yq
    httpie
    gh
    git
    direnv

    # System monitoring
    htop
    btop

    # Terminal tools
    tmux
    atuin
    alacritty

    # Network tools
    nmap
    mtr

    # Language servers and formatters
    rust-analyzer
    # TODO: Add more LSPs as needed

    # Archive tools
    unzip
    p7zip

    # Nix tools
    nix-tree
    nix-output-monitor
    nh
  ];
}
