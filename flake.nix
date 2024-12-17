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

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:

  let
    commonHomeConfig = import ./home/common.nix;

    macConfiguration = { config, pkgs, ... }:
      import ./hosts/mac/configuration.nix { 
        inherit config pkgs;
      };

    nixosConfiguration = { config, pkgs, ... }:
      import ./hosts/linux/configuration.nix {
        inherit config pkgs;
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#bilbo
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      modules = [
        # TODO: fix this
        # ({ config, pkgs, ... }: {
        #   system.configurationRevision = self.rev or self.dirtyRev or null;
        # })
        macConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.cdenneen = commonHomeConfig;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.mac.pkgs;

    nixosConfigurations.linux = nixpkgs.lib.nixosSystem {
      modules = [
        nixosConfiguration
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.cdenneen = commonHomeConfig;
        }
      ];
    };
  };
}
