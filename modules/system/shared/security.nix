# Shared security configuration for all systems
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Security hardening settings that apply to both Darwin and NixOS
  security = {
    # Sudo configuration
    sudo = {
      execWheelOnly = true;  # Only allow wheel group to use sudo
      # Note: wheelNeedsPassword is set per-platform in darwin/nixos modules
    };
  };

  # Platform-specific security configurations
  # Darwin-specific security is handled in modules/system/darwin/
  # NixOS-specific security is handled in modules/system/nixos/

  # Note: Additional security configurations can be added here
  # Examples:
  # - Firewall rules (if cross-platform)
  # - SSH hardening (if applicable to both systems)
  # - System-wide security policies
}
