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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, flake-utils }:

    let
      utils = flake-utils;
      user = "%USER%";
    in
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#mac
        darwinConfigurations.mac = darwin.lib.darwinSystem {
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
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations.mac.pkgs;

        packages = {
          homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [
              ./home.nix
            ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
            extraSpecialArgs = {
              inherit pkgs;
              inherit user;
            };
          };
        };
      });
}
