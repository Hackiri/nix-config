# Security and encryption tools
{pkgs, ...}: {
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
