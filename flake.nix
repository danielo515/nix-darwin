{
  description = "Danielo nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
  }: let
    username = "danielo";
    useremail = "rdanielo@gmail.com";
    system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
    hostname = "Danielos-MacBook-Pro";
    specialArgs = inputs // {inherit username useremail hostname system;};
    configuration = {
      pkgs,
      system,
      ...
    }: {
      # # Conflicts with determinate systems installation
      # nix.enable = false;
      # # Necessary for using flakes on this system.
      # nix.settings.experimental-features = "nix-command flakes";
      # # Set Git commit hash for darwin-version.
      # system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      # nixpkgs.hostPlatform = builtins.trace "System: ${system}" system;
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Danielos-MacBook-Pro
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = import ./home;
        }
      ];
    };
    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
