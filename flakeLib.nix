{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
rec {
  # Helper to create Darwin system configurations
  mkDarwinSystem =
    {
      hostname,
      system,
      username,
    }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;

      specialArgs = {
        inherit inputs self;
      };

      modules = [
        ./system/hosts/${hostname}
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [ self.overlays.customPackages ];
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./home/${username};
            extraSpecialArgs = {
              inherit
                inputs
                self
                username
                hostname
                ;
            };
            # Backup existing files instead of failing
            backupFileExtension = "backup";
            # Add host-specific nix-switch alias for all Darwin hosts
            sharedModules = [
              {
                programs.fish.shellAliases.nix-switch = "nh darwin switch .#darwinConfigurations.${hostname}";
              }
            ];
          };
        }
      ];
    };

  # Helper to create NixOS system configurations
  mkNixosSystem =
    {
      hostname,
      system,
      username,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs self;
      };

      modules = [
        ./system/hosts/${hostname}
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./home/${username};
            extraSpecialArgs = {
              inherit
                inputs
                self
                username
                hostname
                ;
            };
            # Backup existing files instead of failing
            backupFileExtension = "backup";
            # Add host-specific nix-switch alias for all NixOS hosts
            sharedModules = [
              {
                programs.fish.shellAliases.nix-switch = "nh os switch .#nixosConfigurations.${hostname}";
              }
            ];
          };
        }
      ];
    };

  # Helper to create standalone home configurations
  mkHome =
    {
      hostname,
      system,
      username,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      extraSpecialArgs = {
        inherit
          inputs
          self
          username
          hostname
          ;
      };

      modules = [
        ./home/${username}
      ];
    };

  # ForAllSystems helper
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
}
