# Secrets profile - SOPS utilities for encrypted secrets management
# This profile provides sops-nix utilities and shell aliases.
#
# NOTE: Git with sops hooks is now included by default in features/development.nix
#       via base/git.nix. This profile only provides the sops command-line utilities.
#
# ═══════════════════════════════════════════════════════════════════════════
# ⚠️  IMPORTANT: This profile requires setup before use
# ═══════════════════════════════════════════════════════════════════════════
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
# 5. Uncomment this import in features/development.nix
#
# WHAT THIS PROFILE DOES:
# -----------------------
# - Provides sops shell aliases (sops-edit, sops-encrypt, sops-decrypt)
# - Enables sops-nix for encrypted secrets management
#
# NOTE: Git hooks that read from sops are already included via base/git.nix
#       in features/development.nix, so Git will automatically use your
#       encrypted credentials once you set them up.
#
# FILES INCLUDED:
# ---------------
# - ../../programs/utilities/sops-nix/sops.nix (sops utilities)
#
# ═══════════════════════════════════════════════════════════════════════════
{...}: {
  imports = [
    # SOPS utilities and aliases (not included in default utilities)
    ../../programs/utilities/sops-nix/sops.nix
  ];
}
