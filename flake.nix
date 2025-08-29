{
  inputs = {
    # nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # flake-parts - very lightweight flake framework
    # https://flake.parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # home-manager - home user modules
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix - secrets with `sops`
    # https://github.com/Mic92/sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko - declarative disk partitioning and formatting
    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR - Nix User Repository
    # https://github.com/nix-community/NUR
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.chris = import ./home/chris;
            extraSpecialArgs = { inherit attrs; };
            backupFileExtension = "backup";
          };
        }
      ];
    };

    # homeConfigurations = {
    #   "chris@nixos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;

    #     extraSpecialArgs = { inherit attrs; };

    #     modules = [ ./home/chris ];
    #   };
    # };
  };
}
