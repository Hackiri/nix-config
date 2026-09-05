# SOPS Encrypted Secrets Feature
# Purpose: Configure sops-nix when this capability is imported.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/sops.nix ];
#
# Prerequisites (when enabled):
#   1. Generate age key:  age-keygen > ~/.config/sops/age/keys.txt
#   2. Update .sops.yaml with your age public key
#   3. Encrypt secrets:   sops -e -i secrets/secrets.yaml
{
  config,
  hostName,
  lib,
  pkgs,
  ...
}: let
  signingKeySecret = "git-signingKey-${hostName}";
  userNamePath = config.sops.secrets.git-userName.path;
  userEmailPath = config.sops.secrets.git-userEmail.path;
  signingKeyPath = config.sops.secrets.${signingKeySecret}.path;

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
    else
      log_warning "Failed to read sops secrets, git config may be incomplete"
    fi
  '';

  postCheckoutHook = pkgs.writeShellScript "post-checkout-hook" ''
    # Managed by nix-config sops git hooks
    ${applyGitConfig} post-checkout || true
    hook_dir="$(cd "$(dirname "$0")" && pwd)"
    if [[ -x "$hook_dir/post-checkout.local" ]]; then
      exec "$hook_dir/post-checkout.local" "$@"
    fi
  '';

  postMergeHook = pkgs.writeShellScript "post-merge-hook" ''
    # Managed by nix-config sops git hooks
    ${applyGitConfig} post-merge || true
    hook_dir="$(cd "$(dirname "$0")" && pwd)"
    if [[ -x "$hook_dir/post-merge.local" ]]; then
      exec "$hook_dir/post-merge.local" "$@"
    fi
  '';

  installSopsGitHooks = pkgs.writeShellApplication {
    name = "install-sops-git-hooks";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
    ];
    text = ''
      set -euo pipefail
      marker="# Managed by nix-config sops git hooks"

      git rev-parse --git-dir >/dev/null 2>&1
      repo_root="$(git rev-parse --show-toplevel)"
      git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
      hook_dir="$(${pkgs.coreutils}/bin/realpath -m "$(git rev-parse --path-format=absolute --git-path hooks)")"
      repo_root="$(${pkgs.coreutils}/bin/realpath -m "$repo_root")"
      git_common_dir="$(${pkgs.coreutils}/bin/realpath -m "$git_common_dir")"
      case "$hook_dir/" in
        "$repo_root/"* | "$git_common_dir/"*) ;;
        *)
          echo "Refusing to install SOPS hooks outside this repository: $hook_dir" >&2
          echo "Unset the shared core.hooksPath or configure a repository-local hooks directory." >&2
          exit 1
          ;;
      esac
      mkdir -p "$hook_dir"

      install_hook() {
        hook_name="$1"
        source_path="$2"
        hook_path="$hook_dir/$hook_name"
        local_path="$hook_path.local"

        if [[ -e "$hook_path" || -L "$hook_path" ]]; then
          if ! grep -Fq "$marker" "$hook_path" 2>/dev/null; then
            if [[ -e "$local_path" || -L "$local_path" ]]; then
              echo "Refusing to replace $hook_path: $local_path already exists." >&2
              exit 1
            fi
            mv "$hook_path" "$local_path"
            echo "Preserved existing hook at $local_path"
          else
            rm -f "$hook_path"
          fi
        fi

        install -m 0755 "$source_path" "$hook_path"
        echo "Installed $hook_name at $hook_path"
      }

      install_hook post-checkout ${postCheckoutHook}
      install_hook post-merge ${postMergeHook}
    '';
  };
in {
  config = {
    # Sops configuration
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      secrets = {
        git-userName = {
          path = "${config.home.homeDirectory}/.config/git/username";
          mode = "0400";
        };
        git-userEmail = {
          path = "${config.home.homeDirectory}/.config/git/email";
          mode = "0400";
        };
        "${signingKeySecret}" = {
          path = "${config.home.homeDirectory}/.config/git/signingkey";
          mode = "0400";
        };
        ssh-config-srv696730 = {
          path = "${config.home.homeDirectory}/.ssh/conf.d/srv696730";
          mode = "0600";
        };
      };
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
          # New repositories receive the sops hooks without redirecting the
          # repository hook directory (which would suppress pre-commit hooks).
          init.templateDir = "${config.home.homeDirectory}/.config/git/template";
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

    # Git init templates install hooks for future repositories. Existing
    # repositories can opt in or refresh with: install-sops-git-hooks
    home.file = {
      ".config/git/template/hooks/post-checkout" = {
        source = postCheckoutHook;
        executable = true;
      };
      ".config/git/template/hooks/post-merge" = {
        source = postMergeHook;
        executable = true;
      };
      # Create the sops age directory
      ".config/sops/.keep".text = "";
    };

    home.packages = [installSopsGitHooks];

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
