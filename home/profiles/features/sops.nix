# SOPS Encrypted Secrets Feature
# Purpose: Gate all sops-nix configuration behind a feature flag so the repo
#          works out of the box without an age key.
#
# Usage:
#   imports = [ ../../home/profiles/features/sops.nix ];
#
# Configuration:
#   profiles.sops.enable = true;
#
# Prerequisites (when enabled):
#   1. Generate age key:  age-keygen > ~/.config/sops/age/keys.txt
#   2. Update .sops.yaml with your age public key
#   3. Encrypt secrets:   sops -e -i secrets/secrets.yaml
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.sops;

  # Enhanced hook scripts with better error handling and logging
  postCheckoutHook = pkgs.writeShellScript "post-checkout-hook" ''
    set -euo pipefail

    # Color definitions for better output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    log_info() { echo -e "''${BLUE}[INFO]''${NC} $1"; }
    log_success() { echo -e "''${GREEN}[SUCCESS]''${NC} $1"; }
    log_warning() { echo -e "''${YELLOW}[WARNING]''${NC} $1"; }
    log_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }

    log_info "Setting up git configuration from sops secrets..."

    # Check if sops secret files exist and are readable
    # Use warnings instead of errors to avoid breaking plugin updates (e.g., LazyVim)
    if [[ ! -f "${config.sops.secrets.git-userName.path}" ]] ||
       [[ ! -f "${config.sops.secrets.git-userEmail.path}" ]] ||
       [[ ! -f "${config.sops.secrets.git-signingKey.path}" ]]; then
      log_warning "Sops secrets not found, skipping git config setup"
      log_warning "Run 'PATH=/usr/bin:/bin sops-install-secrets' or rebuild home-manager to decrypt secrets"
      exit 0
    fi

    # Read and apply secrets
    if username=$(cat "${config.sops.secrets.git-userName.path}" 2>/dev/null) &&
       email=$(cat "${config.sops.secrets.git-userEmail.path}" 2>/dev/null) &&
       signingkey=$(cat "${config.sops.secrets.git-signingKey.path}" 2>/dev/null); then

      # Validate that secrets are not empty
      if [[ -z "$username" ]] || [[ -z "$email" ]] || [[ -z "$signingkey" ]]; then
        log_warning "Some git secrets are empty, skipping git config setup"
        exit 0
      fi

      # Apply git configuration
      git config user.name "$username" || { log_warning "Failed to set git user.name"; exit 0; }
      git config user.email "$email" || { log_warning "Failed to set git user.email"; exit 0; }
      git config user.signingkey "$signingkey" || { log_warning "Failed to set git user.signingkey"; exit 0; }

      log_success "Git configuration updated successfully!"
      log_info "User: $username <$email>"
    else
      log_warning "Failed to read sops secrets, git config may be incomplete"
    fi
  '';

  postMergeHook = pkgs.writeShellScript "post-merge-hook" ''
    set -euo pipefail

    # Color definitions for better output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    log_info() { echo -e "''${BLUE}[INFO]''${NC} $1"; }
    log_success() { echo -e "''${GREEN}[SUCCESS]''${NC} $1"; }
    log_warning() { echo -e "''${YELLOW}[WARNING]''${NC} $1"; }
    log_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }

    log_info "Post-merge: Updating git configuration from sops secrets..."

    # Check if sops secret files exist and are readable
    if [[ ! -f "${config.sops.secrets.git-userName.path}" ]] ||
       [[ ! -f "${config.sops.secrets.git-userEmail.path}" ]] ||
       [[ ! -f "${config.sops.secrets.git-signingKey.path}" ]]; then
      log_warning "Some sops secret files are missing, skipping git config update"
      exit 0
    fi

    # Read and apply secrets
    if username=$(cat "${config.sops.secrets.git-userName.path}" 2>/dev/null) &&
       email=$(cat "${config.sops.secrets.git-userEmail.path}" 2>/dev/null) &&
       signingkey=$(cat "${config.sops.secrets.git-signingKey.path}" 2>/dev/null); then

      git config user.name "$username"
      git config user.email "$email"
      git config user.signingkey "$signingkey"

      log_success "Git configuration updated after merge!"
    else
      log_warning "Failed to read some sops secrets, git config may be incomplete"
    fi
  '';
in {
  options.profiles.sops = with lib; {
    enable = mkEnableOption "SOPS encrypted secrets management";

    extraSecrets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Destination path for the decrypted secret";
          };
          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "File permissions for the decrypted secret";
          };
        };
      });
      default = {};
      description = "Additional sops secrets beyond the default git credentials";
      example = lib.literalExpression ''
        {
          ssh-config-myhost = {
            path = "''${config.home.homeDirectory}/.ssh/conf.d/myhost";
            mode = "0600";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Sops configuration
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      secrets =
        {
          git-userName = {
            path = "${config.home.homeDirectory}/.config/git/username";
            mode = "0400";
          };
          git-userEmail = {
            path = "${config.home.homeDirectory}/.config/git/email";
            mode = "0400";
          };
          git-signingKey = {
            path = "${config.home.homeDirectory}/.config/git/signingkey";
            mode = "0400";
          };
        }
        // cfg.extraSecrets;
    };

    programs = {
      # Git configuration: only sops-specific additions
      # (base git settings like delta, difftool, mergetool, signing
      #  are already defined in programs/development/git/default.nix)
      git = {
        enable = true;
        signing = {
          signByDefault = true;
        };
        settings = {
          # Init template for sops hooks
          init.templateDir = "${config.home.homeDirectory}/.git-template";
        };
      };

      # Shell aliases for sops convenience
      zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
        sops-edit = "sops";
        sops-encrypt = "sops -e -i";
        sops-decrypt = "sops -d";
      };

      bash.shellAliases = lib.mkIf config.programs.bash.enable {
        sops-edit = "sops";
        sops-encrypt = "sops -e -i";
        sops-decrypt = "sops -d";
      };
    };

    # Git template directory with sops hooks
    home.file = {
      ".git-template/hooks/post-checkout" = {
        source = postCheckoutHook;
        executable = true;
      };
      ".git-template/hooks/post-merge" = {
        source = postMergeHook;
        executable = true;
      };
      # Create the sops age directory
      ".config/sops/.keep".text = "";
    };

    # Enforce restrictive permissions on age key (Critical: prevents local reads)
    home.activation.fixSopsPermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "${config.home.homeDirectory}/.config/sops/age/keys.txt" ]; then
        chmod 600 "${config.home.homeDirectory}/.config/sops/age/keys.txt"
        chmod 700 "${config.home.homeDirectory}/.config/sops/age"
      fi
    '';

    # Fix sops-nix launchd service PATH (Darwin only)
    launchd.agents."sops-nix" = lib.mkIf pkgs.stdenv.isDarwin {
      config.EnvironmentVariables.PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };
}
