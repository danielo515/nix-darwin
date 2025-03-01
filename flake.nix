{
  description = "Danielo's Nix configuration for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";

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
    inputs@{ self, nixpkgs, flake-parts, nix-darwin, home-manager, ... }:
    let
      # Define common variables
      username = "danielo";
      useremail = "rdanielo@gmail.com";
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];

      perSystem = { system, pkgs, lib, ... }: {
        # Formatter for each system
        formatter = pkgs.alejandra;

        # Development shells
        devShells.default =
          pkgs.mkShell { buildInputs = [ pkgs.nixd pkgs.just ]; };

        # Custom packages
        packages = import ./pkgs { inherit pkgs; } // {
          # Set repo-cloner as the default package
          default = pkgs.callPackage ./pkgs/repo-cloner { };
          hola = (pkgs.writeShellApplication {
            name = "hola";
            text = ''echo "Hola, mundo!" '';
          });
        };
      };

      flake = {
        # Darwin configurations
        darwinConfigurations = let
          # Common special arguments for all configurations
          commonSpecialArgs = { inherit username useremail; };

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
                {
                  # Home Manager configuration
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = commonSpecialArgs // {
                    isDarwin = true;
                    flake = self;
                  };
                  home-manager.users.${username} = import ./home;
                  home-manager.backupFileExtension = "home-bk";
                }

                # Include overlays
                { nixpkgs.overlays = import ./overlays; }
              ];
            };
        in builtins.mapAttrs mkDarwinConfig darwinHosts;

        # Standalone home-manager configurations
        homeConfigurations = let
          # Common special arguments for all configurations
          commonSpecialArgs = { inherit username useremail; };

          # Function to create standalone home-manager configuration
          mkHomeConfig = system: isDarwin:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [ ./home ];
              extraSpecialArgs = commonSpecialArgs // { inherit isDarwin; };
            };
        in {
          # Darwin standalone home configuration
          "${username}-darwin" = mkHomeConfig "aarch64-darwin" true;

          # Linux standalone home configuration
          "${username}-linux" = mkHomeConfig "x86_64-linux" false;
        };
      };
    };
}
