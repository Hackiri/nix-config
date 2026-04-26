# SOPS Encrypted Secrets Feature
# Purpose: Gate all sops-nix configuration behind a feature flag so the repo
#          works out of the box without an age key.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/sops.nix ];
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

  userNamePath = config.sops.secrets.git-userName.path;
  userEmailPath = config.sops.secrets.git-userEmail.path;
  signingKeyPath = config.sops.secrets.${cfg.signingKeySecret}.path;

  # Shared script applied by post-checkout and post-merge hooks.
  # Reads decrypted sops secrets and applies them to git config; warns instead
  # of failing so plugin updates (e.g., LazyVim) aren't broken when secrets
  # are missing.
  applyGitConfig = pkgs.writeShellScript "sops-apply-git-config" ''
    set -euo pipefail

    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    log_info()    { echo -e "''${BLUE}[INFO]''${NC} $1"; }
    log_success() { echo -e "''${GREEN}[SUCCESS]''${NC} $1"; }
    log_warning() { echo -e "''${YELLOW}[WARNING]''${NC} $1"; }

    context="''${1:-update}"
    log_info "Applying git configuration from sops secrets ($context)..."

    if [[ ! -f "${userNamePath}" ]] ||
       [[ ! -f "${userEmailPath}" ]] ||
       [[ ! -f "${signingKeyPath}" ]]; then
      log_warning "Sops secrets not found, skipping git config setup"
      log_warning "Run 'PATH=/usr/bin:/bin sops-install-secrets' or rebuild home-manager to decrypt secrets"
      exit 0
    fi

    if username=$(cat "${userNamePath}" 2>/dev/null) &&
       email=$(cat "${userEmailPath}" 2>/dev/null) &&
       signingkey=$(cat "${signingKeyPath}" 2>/dev/null); then

      if [[ -z "$username" ]] || [[ -z "$email" ]] || [[ -z "$signingkey" ]]; then
        log_warning "Some git secrets are empty, skipping git config setup"
        exit 0
      fi

      git config user.name       "$username"   || { log_warning "Failed to set git user.name";       exit 0; }
      git config user.email      "$email"      || { log_warning "Failed to set git user.email";      exit 0; }
      git config user.signingkey "$signingkey" || { log_warning "Failed to set git user.signingkey"; exit 0; }

      log_success "Git configuration applied ($context)"
      log_info "User: $username <$email>"
    else
      log_warning "Failed to read sops secrets, git config may be incomplete"
    fi
  '';

  postCheckoutHook = pkgs.writeShellScript "post-checkout-hook" ''
    exec ${applyGitConfig} post-checkout
  '';

  postMergeHook = pkgs.writeShellScript "post-merge-hook" ''
    exec ${applyGitConfig} post-merge
  '';
in {
  options.profiles.sops = with lib; {
    enable = mkEnableOption "SOPS encrypted secrets management";

    signingKeySecret = mkOption {
      type = types.str;
      default = "git-signingKey";
      description = "Name of the sops secret to use for the git signing key (allows per-host GPG keys)";
    };

    extraSecrets = mkOption {
      type = types.attrsOf (
        types.submodule {
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
        }
      );
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
          "${cfg.signingKeySecret}" = {
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
          # Apply hooks to existing repositories as well as future clones.
          core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
        };
      };

      # Shell aliases for sops convenience
      zsh = lib.mkIf config.programs.zsh.enable {
        shellAliases = {
          sops-edit = "sops";
          sops-encrypt = "sops -e -i";
          sops-decrypt = "sops -d";
        };
        sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };

      bash = lib.mkIf config.programs.bash.enable {
        shellAliases = {
          sops-edit = "sops";
          sops-encrypt = "sops -e -i";
          sops-decrypt = "sops -d";
        };
        sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };

    # Git template directory with sops hooks
    home.file = {
      ".config/git/hooks/post-checkout" = {
        source = postCheckoutHook;
        executable = true;
      };
      ".config/git/hooks/post-merge" = {
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
