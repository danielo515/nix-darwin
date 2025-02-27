{
  description = "Danielo's Nix configuration for macOS";

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

      # Generate all Darwin configurations
      darwinConfigurations = builtins.mapAttrs mkDarwinConfig darwinHosts;

      # Standalone home-manager configuration for any system
      mkHomeConfig = system: isDarwin:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home ];
          extraSpecialArgs = commonSpecialArgs // { inherit isDarwin; };
        };

    in {
      # Export the configurations
      inherit darwinConfigurations;
      
      # Standalone home-manager configurations for different systems
      homeConfigurations = {
        # Darwin standalone home configuration
        "${username}-darwin" = mkHomeConfig darwinSystems.0 true;
        
        # Linux standalone home configuration
        "${username}-linux" = mkHomeConfig nixosSystems.0 false;
      };

      # Nix code formatter for all systems
      formatter = builtins.listToAttrs (map
        (system: {
          name = system;
          value = nixpkgs.legacyPackages.${system}.alejandra;
        })
        (darwinSystems ++ nixosSystems));

      # Development shells
      devShells = builtins.listToAttrs (map
        (system: {
          name = system;
          value = {
            default = nixpkgs.legacyPackages.${system}.mkShell {
              buildInputs = [ nixpkgs.legacyPackages.${system}.nixd ];
            };
          };
        })
        (darwinSystems ++ nixosSystems));
    };
}
