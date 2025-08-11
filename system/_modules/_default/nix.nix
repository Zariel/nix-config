{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Only configure Nix settings if nix-darwin is managing Nix
  config = lib.mkIf (config.nix.enable or true) {
    nix = {
      settings = {
        # Enable flakes
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Users allowed to use Nix
        trusted-users = [
          "root"
          "@wheel"
        ];

        # Binary cache settings
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Garbage collection
        min-free = lib.mkDefault (1024 * 1024 * 1024); # 1GB
        max-free = lib.mkDefault (5 * 1024 * 1024 * 1024); # 5GB
      };

      # Optimize store automatically
      optimise.automatic = true;

      # Garbage collection
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
    };

    # Only include English documentation
    environment.variables = {
      MANPAGER = "less -R";
      LANG = "en_GB.UTF-8";
    };
  };
}
