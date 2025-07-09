{ config, lib, pkgs, ... }:
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
    
    # Development tools
    jq
    yq
    httpie
    
    # System monitoring
    htop
    btop
    ncdu
    
    # Terminal tools
    tmux
    atuin
    
    # Nix tools
    nix-tree
    nix-output-monitor
    nh
  ];
}