# System builder functions: mkPkgs, mkHomeManagerConfig, mkDarwin, mkNixOS, discoverHosts
{inputs}: let
  inherit (inputs.nixpkgs) lib;
  overlay = import ../overlays {inherit inputs;};

  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.emacs-overlay.overlays.default
        overlay
      ];
      config = {
        allowUnfree = true;
        allowDeprecatedx86_64Darwin = true;
      };
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
    system ? "x86_64-darwin",
    username ? "wm",
  }: let
    pkgs = mkPkgs system;
  in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        ../hosts/${name}/configuration.nix
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        (mkHomeManagerConfig {inherit name username;})
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
      specialArgs = {inherit inputs system username;};
    };

  mkNixOS = {
    name,
    system ? "x86_64-linux",
    username ? "wm",
  }: let
    pkgs = mkPkgs system;
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ../hosts/${name}/configuration.nix
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerConfig {inherit name username;})
      ];
      specialArgs = {inherit inputs system username;};
    };
  # Auto-discover hosts from hosts/ directory via meta.nix metadata files
  discoverHosts = let
    hostsDir = ../hosts;
    hostNames =
      builtins.attrNames
      (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));
    hostMetas =
      map (name: {
        inherit name;
        meta = import ../hosts/${name}/meta.nix;
      })
      hostNames;
    darwinHosts = builtins.filter (h: h.meta.type == "darwin") hostMetas;
    nixosHosts = builtins.filter (h: h.meta.type == "nixos") hostMetas;
  in {
    darwinConfigurations = lib.listToAttrs (map (h: {
        inherit (h) name;
        value = mkDarwin {
          inherit (h) name;
          inherit (h.meta) system username;
        };
      })
      darwinHosts);
    nixosConfigurations = lib.listToAttrs (map (h: {
        inherit (h) name;
        value = mkNixOS {
          inherit (h) name;
          inherit (h.meta) system username;
        };
      })
      nixosHosts);
  };
in {
  inherit mkPkgs mkHomeManagerConfig mkDarwin mkNixOS discoverHosts;
}
