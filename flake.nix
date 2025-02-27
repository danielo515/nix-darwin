{
  description = "Danielo's Nix configuration for both NixOS and Darwin";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Darwin-specific inputs
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-utils, nixpkgs, nix-darwin, home-manager, ... }:
    let
      username = "danielo";
      useremail = "rdanielo@gmail.com";

      # Common special arguments for all configurations
      commonSpecialArgs = { inherit username useremail; };

      # System types
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      nixosSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Host configurations
      darwinHosts = {
        "Danielos-MacBook-Pro" = {
          system = "aarch64-darwin";
          hostPath = ./hosts/macbook;
        };
        # Add more macOS hosts here as needed
        # "Danielos-iMac" = {
        #   system = "aarch64-darwin";
        #   hostPath = ./hosts/imac;
        # };
      };

      nixosHosts = {
        "desktop" = {
          system = "x86_64-linux";
          hostPath = ./hosts/desktop;
        };
        "laptop" = {
          system = "x86_64-linux";
          hostPath = ./hosts/laptop;
        };
        # Add more NixOS hosts here as needed
      };

      # Function to create home-manager configuration for a host
      mkHomeManagerConfig = { system, hostname, extraSpecialArgs ? { } }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = commonSpecialArgs // extraSpecialArgs;
        home-manager.users.${username} = import ./home;
        home-manager.backupFileExtension = "home-bk";
      };

      # Function to create a Darwin configuration
      mkDarwinConfig = hostname: hostConfig:
        nix-darwin.lib.darwinSystem {
          system = hostConfig.system;
          specialArgs = commonSpecialArgs // {
            hostname = hostname;
            system = hostConfig.system;
            isDarwin = true;
          };
          modules = [
            # Host-specific configuration
            hostConfig.hostPath

            # Include home-manager module
            home-manager.darwinModules.home-manager
            (mkHomeManagerConfig {
              system = hostConfig.system;
              hostname = hostname;
              extraSpecialArgs = { isDarwin = true; };
            })

            # Include overlays
            { nixpkgs.overlays = import ./overlays; }
          ];
        };

      # Function to create a NixOS configuration
      mkNixosConfig = hostname: hostConfig:
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = commonSpecialArgs // {
            inherit (inputs) home-manager;
            hostname = hostname;
            system = hostConfig.system;
            isDarwin = false;
          };
          modules = [
            # Host-specific configuration
            hostConfig.hostPath
            (_: {
              boot.loader.grub.device =
                "/dev/disk/by-id/wwn-0x500001234567890a";
            })
            # Include home-manager module
            home-manager.nixosModules.home-manager
            (mkHomeManagerConfig {
              system = hostConfig.system;
              hostname = hostname;
              extraSpecialArgs = { isDarwin = false; };
            })

            # Include overlays
            { nixpkgs.overlays = import ./overlays; }
          ];
        };

      # Generate all Darwin configurations
      darwinConfigurations = builtins.mapAttrs mkDarwinConfig darwinHosts;

      # Generate all NixOS configurations
      nixosConfigurations = builtins.mapAttrs mkNixosConfig nixosHosts;

    in {
      # Export the configurations
      inherit darwinConfigurations nixosConfigurations;

      # Nix code formatter for all systems
      formatter = flake-utils.lib.eachDefaultSystem
        (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Development shells
      devShells = flake-utils.lib.eachDefaultSystemPassThrough (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          ${system}.default = pkgs.mkShell { buildInputs = [ pkgs.nixd ]; };
        });
    };
}
