# Security and encryption tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.packages.enable or true)
      && (config.profiles.development.packages.security.enable or true)
    )
    {
      home.packages = with pkgs; [
        #--------------------------------------------------
        # Secrets Management
        #--------------------------------------------------
        sops # Secrets OPerationS - encrypted secrets management
        age # Simple, modern encryption tool

        #--------------------------------------------------
        # Security Auditing & Analysis
        #--------------------------------------------------
        lynis # Security auditing tool for Unix systems
        trivy # Vulnerability scanner for containers and filesystems
        vulnix # Nix vulnerability scanner (PKGS-7398)
        clamav # On-demand malware scanning (HRDN-7230)

        #--------------------------------------------------
        # Password & Credential Tools
        #--------------------------------------------------
        pwgen # Password generator
        pass # Unix password manager (GPG-based)

        #--------------------------------------------------
        # Network Security
        #--------------------------------------------------
        nmap # Network exploration and security auditing
      ];
    };
}
