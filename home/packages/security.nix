# Security and encryption tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Secrets Management
    #--------------------------------------------------
    sops # Secrets OPerationS - encrypted secrets management
    age # Simple, modern encryption tool
    
    #--------------------------------------------------
    # Additional Security Tools (add as needed)
    #--------------------------------------------------
    # gnupg # GNU Privacy Guard
    # pass # Standard Unix password manager
    # bitwarden-cli # Bitwarden command-line interface
  ];
}
