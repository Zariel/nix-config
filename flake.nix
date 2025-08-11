{
  description = "Zariel's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # macOS system management
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      flakeLib = import ./flakeLib.nix { inherit self inputs; };
      inherit (flakeLib)
        mkDarwinSystem
        mkNixosSystem
        mkHome
        forAllSystems
        ;
    in
    {
      # Overlays
      overlays = import ./overlays { inherit inputs; };

      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            # Nix tools
            nixfmt-rfc-style
            nil
            nix-prefetch
            hydra-check
          ];
        };
      });

      # macOS configurations
      darwinConfigurations = {
        macbook = mkDarwinSystem {
          hostname = "macbook";
          system = "aarch64-darwin";
          username = "chrisbannister";
        };
      };

      # NixOS configurations (for future use)
      nixosConfigurations = {
        # router = mkNixosSystem {
        #   hostname = "router";
        #   system = "x86_64-linux";
        #   username = "chris";
        # };
      };

      # Standalone home configurations
      homeConfigurations = {
        "chrisbannister@macbook" = mkHome {
          hostname = "macbook";
          system = "aarch64-darwin";
          username = "chrisbannister";
        };
      };

      # Checks
      checks = forAllSystems (system: {
        # Add checks here
      });
    };
}
