# Profile-Only Architecture Migration - Current State Backup

## Current Shared Config Imports (Before Removal)

### Home Manager Imports
- `hosts/mbp/home.nix` imports `../../home/shared/base.nix`
- `hosts/desktop/home.nix` imports `../../home/shared/base.nix`

### System Configuration Imports  
- `hosts/mbp/configuration.nix` imports `../shared/base.nix`
- `hosts/desktop/configuration.nix` imports `../shared/base.nix`

## Current Shared Config Contents

### `home/shared/base.nix`
```nix
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home = {
    inherit username;
    stateVersion = "25.05";
    packages = with pkgs; [
      # Empty - no packages defined
    ];
  };

  programs = {
    home-manager.enable = true;
  };
}
```

### `hosts/shared/base.nix`
```nix
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Host-level shared configuration can go here
  # Most functionality has been moved to modules/system/shared/
}
```

### `hosts/shared/users.nix`
```nix
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Common user settings that apply to both Darwin and NixOS
  # This can be extended with more shared user configurations

  # Placeholder for shared user configurations
  # Add common user settings here that should apply to all hosts
}
```

## Current Profile Structure (To Be Enhanced)

### `home/profiles/minimal.nix`
- Imports: shells/default.nix, utilities/btop
- Note: References system.nix for packages

### `home/profiles/development.nix`
- Imports: editors, development, terminals, shells, utilities, packages, custom

### `home/profiles/macos.nix`
- Imports: development.nix, darwin.nix, utilities/aerospace

### `home/profiles/nixos.nix`
- Imports: development.nix, nixos.nix

## Migration Plan
1. Enhance minimal.nix with essential cross-platform packages
2. Update profile inheritance chain
3. Remove shared config imports from hosts
4. Remove empty shared config files
5. Test on both systems

Date: 2025-09-28
