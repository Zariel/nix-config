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
    
    # Helper to create user configs based on hostname
    mkUser = hostname: 
      if hostname == "macbook" then "chrisbannister"
      else "chris";
    
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
          
          # Language servers for Helix
          gopls
          texlab
          ltex-ls
          ruff
          pyright
        ];
        
        shellHook = ''
          echo "🚀 Nix development environment loaded!"
          echo "Available tools: nixfmt, nil, deploy-rs, git, helix, fish"
          
          # Set up Helix config if it doesn't exist
          mkdir -p ~/.config/helix
          if [ ! -f ~/.config/helix/config.toml ]; then
            cat > ~/.config/helix/config.toml << 'EOF'
theme = "penumbra+"

[editor]
end-of-line-diagnostics = "hint"

[editor.inline-diagnostics]
cursor-line = "error"

[editor.soft-wrap]
enable = true

[keys.normal]
"C-d" = ["move_prev_word_start", "move_next_word_end", "search_selection", "extend_search_next"]
EOF
          fi
          
          if [ ! -f ~/.config/helix/languages.toml ]; then
            cat > ~/.config/helix/languages.toml << 'EOF'
[language-server.gopls.config]
"formatting.gofumpt" = true

[language-server.ltex-ls.config.ltex]
language = "en-GB"

[[language]]
name = "latex"
language-servers = [ "texlab", "ltex-ls" ]

[[language]]
name = "go"
auto-format = true

[[language]]
name = "python"
formatter = { command = "ruff", args = ["format", "--line-length", "88", "-"] }
auto-format = true

[[language]]
name = "nix"
auto-format = true
formatter = { command = "nixfmt" }
EOF
          fi
        '';
      };
    });

    # macOS configurations
    darwinConfigurations = {
      macbook = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { 
          inherit inputs outputs; 
          username = mkUser "macbook";
        };
        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${mkUser "macbook"} = import ./home;
              extraSpecialArgs = { 
                inherit inputs outputs; 
                username = mkUser "macbook";
                hostname = "macbook";
              };
            };
          }
        ];
      };
    };

    # NixOS configurations
    nixosConfigurations = {
      router = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs outputs; 
          username = mkUser "router";
        };
        modules = [
          ./hosts/router
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${mkUser "router"} = import ./home;
              extraSpecialArgs = { 
                inherit inputs outputs; 
                username = mkUser "router";
                hostname = "router";
              };
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