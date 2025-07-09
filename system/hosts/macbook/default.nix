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

  # System configuration
  networking.hostName = "macbook";
  networking.computerName = "macbook";
  system.stateVersion = 5;

  # Primary user required for many Darwin settings
  system.primaryUser = "chrisbannister";

  # Enable homebrew integration
  # myModules.darwin.homebrew.enable = true;  # Disabled when nix.enable = false

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
