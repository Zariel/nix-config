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

    # Deployment tool
    deploy-rs = {
      url = "github:serokell/deploy-rs";
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
      # Development shells
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            # Nix tools
            nixfmt-rfc-style
            nil

            # Deployment
            inputs.deploy-rs.packages.${system}.default

            # Development tools
            git
            helix
            fish

            # CLI tools that fish aliases expect
            eza
            bat
            ripgrep
            fd
            zoxide
            fzf
          ];

          shellHook = ''
            echo "🚀 Nix development environment loaded!"
            echo "Available tools: nixfmt, nil, deploy-rs, git, helix, fish, eza, bat, ripgrep"
          '';
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

      # Deploy-rs configuration (for future use)
      # deploy.nodes.router = {
      #   hostname = "router.local";
      #   profiles.system = {
      #     user = "root";
      #     path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.router;
      #     remoteBuild = true;
      #   };
      # };

      # Checks
      checks = forAllSystems (system: {
        # Add checks here
      });
    };
}
