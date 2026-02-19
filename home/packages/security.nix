# Security and encryption tools
{
  pkgs,
  pkgs-unstable,
  ...
}: {
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
    pkgs-unstable.trivy # Vulnerability scanner for containers and filesystems (unstable for latest CVE data)
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
}
