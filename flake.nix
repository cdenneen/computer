# Nix config
# Chris Denneen / shadowsector.org
# Created 2024-12-17

# Tested with https://determinate.systems installer

# Sources that helped me set this up:
#  - https://davi.sh/blog/2024/01/nix-darwin/
#  - https://nixcademy.com/posts/nix-on-macos/
#  - https://github.com/mirkolenz/nixos/blob/main/system/darwin/settings.nix

{
  description = "Chris Denneen system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs }:

    let
      user = "%USER%";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.getAttrs (linuxSystems ++ darwinSystems) f;

    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system: let
        user = "%USER%";
      in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );

      defaultPackage = {
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
        aarch64-linux = home-manager.defaultPackage.aarch64-linux;
        x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      };

      homeConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: let
        user = "%USER%";
      in
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/nixos
          ];
        }
      );
   };
}
