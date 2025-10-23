# Secrets profile - Git hooks with sops-nix integration
# This profile configures Git with encrypted secrets management using sops-nix.
#
# ═══════════════════════════════════════════════════════════════════════════
# ⚠️  IMPORTANT: This profile requires setup before use
# ═══════════════════════════════════════════════════════════════════════════
#
# QUICK START FOR NEW USERS:
# -------------------------
# 1. Comment out this import in development.nix:
#    # ./secrets.nix  # <-- Add # to disable
#
# 2. Configure Git manually after installation:
#    git config --global user.name "Your Name"
#    git config --global user.email "your@email.com"
#    git config --global user.signingkey "YOUR_GPG_KEY_ID"
#
# ADVANCED SETUP (for encrypted secrets):
# ---------------------------------------
# 1. Generate age key:
#    mkdir -p ~/.config/sops/age
#    age-keygen > ~/.config/sops/age/keys.txt
#
# 2. Get your public key:
#    grep "public key:" ~/.config/sops/age/keys.txt
#
# 3. Update .sops.yaml with your age public key:
#    keys:
#      - &main-key age1your_public_key_here
#
# 4. Create and encrypt secrets/secrets.yaml:
#    sops secrets/secrets.yaml
#    # Add: git-userName, git-userEmail, git-signingKey
#
# 5. Uncomment this import in development.nix
#
# WHAT THIS PROFILE DOES:
# -----------------------
# - Installs Git hooks (post-checkout, post-merge) that auto-configure Git
# - Reads Git credentials from encrypted sops secrets
# - Provides sops shell aliases (sops-edit, sops-encrypt, sops-decrypt)
# - Configures GPG for commit signing
#
# FILES INCLUDED:
# ---------------
# - ../programs/development/git/git-hooks.nix (Git + sops hooks)
# - ../programs/utilities/sops-nix/sops.nix (sops utilities)
#
# ═══════════════════════════════════════════════════════════════════════════
{...}: {
  imports = [
    # Git configuration with sops-integrated hooks
    ../programs/development/git/git-hooks.nix

    # SOPS utilities and aliases
    ../programs/utilities/sops-nix/sops.nix
  ];
}
