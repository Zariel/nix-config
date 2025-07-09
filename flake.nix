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
    
    # Secrets management (sops fallback)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nix-darwin, home-manager, deploy-rs, sops-nix, ... }@inputs: 
  let
    inherit (self) outputs;
    
    # Supported systems
    systems = [ "aarch64-darwin" "x86_64-linux" ];
    
    # Helper function to generate configs for each system
    forAllSystems = nixpkgs.lib.genAttrs systems;
    
    # Create pkgs for each system
    pkgsFor = nixpkgs.lib.genAttrs systems (system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    });
  in
  {
    # Development shells for each system
    devShells = forAllSystems (system: {
      default = pkgsFor.${system}.mkShell {
        buildInputs = with pkgsFor.${system}; [
          # Nix tools
          nixfmt-rfc-style
          nil  # Nix LSP
          
          # Deployment
          deploy-rs.packages.${system}.default
          
          # Development tools
          git
          helix
          fish
        ];
        
        shellHook = ''
          echo "🚀 Nix development environment loaded!"
          echo "Available tools: nixfmt, nil, deploy-rs, git, helix, fish"
        '';
      };
    });

    # macOS configurations
    darwinConfigurations = {
      macbook = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.zariel = import ./home/darwin.nix;
              extraSpecialArgs = { inherit inputs outputs; };
            };
          }
        ];
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      router = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/router
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.zariel = import ./home/nixos.nix;
              extraSpecialArgs = { inherit inputs outputs; };
            };
          }
        ];
      };
    };

    # Deploy-rs configuration
    deploy.nodes.router = {
      hostname = "router.local";  # Adjust as needed
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.router;
        remoteBuild = true;
      };
    };

    # Deploy-rs checks
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}