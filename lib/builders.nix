# System builder functions: mkHomeManagerConfig, mkDarwin, mkNixOS, discoverHosts
{
  inputs,
  defaultUsername,
}: let
  inherit (inputs.nixpkgs) lib;
  overlay = import ../overlays {inherit inputs;};
  readHostMeta = name: let
    hostDir = ../hosts/${name};
    metaPath = hostDir + "/meta.nix";
    configurationPath = hostDir + "/configuration.nix";
    homePath = hostDir + "/home.nix";
    meta = import metaPath;
  in
    assert lib.assertMsg (builtins.pathExists metaPath) "Host '${name}' is missing hosts/${name}/meta.nix";
    assert lib.assertMsg (builtins.pathExists configurationPath) "Host '${name}' is missing hosts/${name}/configuration.nix";
    assert lib.assertMsg (builtins.pathExists homePath) "Host '${name}' is missing hosts/${name}/home.nix";
    assert lib.assertMsg (builtins.isAttrs meta) "Host '${name}' metadata must evaluate to an attrset";
    assert lib.assertMsg (meta ? type) "Host '${name}' metadata must define 'type'";
    assert lib.assertMsg (meta ? system) "Host '${name}' metadata must define 'system'";
    assert lib.assertMsg (meta ? device) "Host '${name}' metadata must define 'device'";
    assert lib.assertMsg (builtins.elem meta.type ["darwin" "nixos"]) "Host '${name}' metadata type must be 'darwin' or 'nixos'"; {
      inherit name meta;
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
        inherit inputs username;
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
            config = {
              allowUnfree = true;
              allowDeprecatedx86_64Darwin = system == "x86_64-darwin";
            };
          };
        }
        ../hosts/${name}/configuration.nix
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        (mkHomeManagerConfig {inherit name username;})
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          device = {
            type = device;
            hostname = name;
          };
        }
      ];
      specialArgs = {inherit inputs username;};
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
      specialArgs = {inherit inputs username;};
    };

  # Auto-discover hosts from hosts/ directory via meta.nix metadata files
  discoverHosts = let
    hostsDir = ../hosts;
    hostNames =
      builtins.attrNames
      (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));
    hostMetas = map readHostMeta hostNames;
    darwinHosts = builtins.filter (h: h.meta.type == "darwin") hostMetas;
    nixosHosts = builtins.filter (h: h.meta.type == "nixos") hostMetas;
  in {
    darwinConfigurations = lib.listToAttrs (map (h: {
        inherit (h) name;
        value = mkDarwin {
          inherit (h) name;
          inherit (h.meta) system device;
          username = h.meta.username or defaultUsername;
        };
      })
      darwinHosts);
    nixosConfigurations = lib.listToAttrs (map (h: {
        inherit (h) name;
        value = mkNixOS {
          inherit (h) name;
          inherit (h.meta) system device;
          username = h.meta.username or defaultUsername;
        };
      })
      nixosHosts);
  };
in {
  inherit mkHomeManagerConfig mkDarwin mkNixOS discoverHosts;
}
