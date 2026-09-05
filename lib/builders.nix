# System builder functions: mkHomeManagerConfig, mkDarwin, mkNixOS, discoverHosts
{
  inputs,
  defaultUsername,
}: let
  overlay = import ../overlays {inherit inputs;};
  hostInventory = import ./host-inventory.nix {
    hostsDir = ../hosts;
    inherit defaultUsername;
  };

  mkHomeManagerConfig = {
    name,
    username,
  }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs username hostInventory;
        hostName = name;
      };
      users.${username} = import ../hosts/${name}/home.nix;
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        {manual.json.enable = false;}
      ];
    };
  };

  mkDarwin = {
    name,
    system ? "aarch64-darwin",
    username ? defaultUsername,
    device ? "desktop",
  }:
    inputs.nix-darwin.lib.darwinSystem {
      modules = [
        {
          nixpkgs = {
            hostPlatform = system;
            overlays = [
              inputs.emacs-overlay.overlays.default
              overlay
            ];
            config.allowUnfree = true;
          };
        }
        ../hosts/${name}/configuration.nix
        inputs.determinate.darwinModules.default
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        (mkHomeManagerConfig {inherit name username;})
        {
          device = {
            type = device;
            hostname = name;
          };
        }
      ];
      specialArgs = {inherit inputs username hostInventory;};
    };

  mkNixOS = {
    name,
    system ? "x86_64-linux",
    username ? defaultUsername,
    device ? "desktop",
  }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs = {
            hostPlatform = system;
            overlays = [
              inputs.emacs-overlay.overlays.default
              overlay
            ];
            config.allowUnfree = true;
          };
        }
        ../hosts/${name}/configuration.nix
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerConfig {inherit name username;})
        {
          device = {
            type = device;
            hostname = name;
          };
        }
      ];
      specialArgs = {inherit inputs username hostInventory;};
    };

  hostMetas = builtins.attrValues hostInventory;
  darwinHosts = builtins.filter (host: host.type == "darwin") hostMetas;
  nixosHosts = builtins.filter (host: host.type == "nixos") hostMetas;
  discoverHosts = {
    darwinConfigurations = builtins.listToAttrs (
      map (host: {
        inherit (host) name;
        value = mkDarwin {
          inherit (host) name system device username;
        };
      })
      darwinHosts
    );
    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        inherit (host) name;
        value = mkNixOS {
          inherit (host) name system device username;
        };
      })
      nixosHosts
    );
  };
in {
  inherit
    mkHomeManagerConfig
    mkDarwin
    mkNixOS
    hostInventory
    discoverHosts
    ;
}
