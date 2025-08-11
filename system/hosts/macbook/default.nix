{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../_modules
  ];

  # Disable nix-darwin's Nix management (using Determinate Systems)
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System configuration
  networking.hostName = "macbook";
  networking.computerName = "macbook";
  system.stateVersion = 5;

  # Primary user required for many Darwin settings
  system.primaryUser = "chrisbannister";

  homebrew.casks = [
    "1password"
    "firefox"
    "xld"
    "docker"
    "roon"
    "obsidian"
    "vlc"
    "multiviewer-for-f1"
    "balenaetcher"
    "discord"
  ];

  system.defaults.dock.persistent-apps = lib.mkAfter [
    "${pkgs.alacritty}/Applications/Alacritty.app"
    "/Applications/Firefox.app"
    "/Applications/Roon.app"
    "/Applications/Discord.app"
  ];

  # User configuration
  users.users.chrisbannister = {
    name = "chrisbannister";
    home = "/Users/chrisbannister";
    description = "Chris Bannister";
    shell = pkgs.fish;
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;
}
