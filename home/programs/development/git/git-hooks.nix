{
  pkgs,
  lib,
  config,
  inputs ? {},
  ...
}: let
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
    secrets_dir="${config.home.homeDirectory}/.config/git"

    if [[ ! -f "${config.sops.secrets.git-userName.path}" ]]; then
      log_error "Git username secret not found at ${config.sops.secrets.git-userName.path}"
      exit 1
    fi

    if [[ ! -f "${config.sops.secrets.git-userEmail.path}" ]]; then
      log_error "Git email secret not found at ${config.sops.secrets.git-userEmail.path}"
      exit 1
    fi

    if [[ ! -f "${config.sops.secrets.git-signingKey.path}" ]]; then
      log_error "Git signing key secret not found at ${config.sops.secrets.git-signingKey.path}"
      exit 1
    fi

    # Read secrets with error handling
    if ! username=$(cat "${config.sops.secrets.git-userName.path}" 2>/dev/null); then
      log_error "Failed to read git username from sops secret"
      exit 1
    fi

    if ! email=$(cat "${config.sops.secrets.git-userEmail.path}" 2>/dev/null); then
      log_error "Failed to read git email from sops secret"
      exit 1
    fi

    if ! signingkey=$(cat "${config.sops.secrets.git-signingKey.path}" 2>/dev/null); then
      log_error "Failed to read git signing key from sops secret"
      exit 1
    fi

    # Validate that secrets are not empty
    if [[ -z "$username" ]]; then
      log_error "Git username is empty"
      exit 1
    fi

    if [[ -z "$email" ]]; then
      log_error "Git email is empty"
      exit 1
    fi

    if [[ -z "$signingkey" ]]; then
      log_error "Git signing key is empty"
      exit 1
    fi

    # Apply git configuration
    git config user.name "$username" || { log_error "Failed to set git user.name"; exit 1; }
    git config user.email "$email" || { log_error "Failed to set git user.email"; exit 1; }
    git config user.signingkey "$signingkey" || { log_error "Failed to set git user.signingkey"; exit 1; }

    log_success "Git configuration updated successfully!"
    log_info "User: $username <$email>"
    log_info "Signing key: $signingkey"
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

  preCommitHook = pkgs.writeShellScript "pre-commit-hook" ''
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

    log_info "Running pre-commit hooks..."

    # Check if pre-commit is available
    if ! command -v ${pkgs.pre-commit}/bin/pre-commit >/dev/null 2>&1; then
      log_warning "pre-commit not found, skipping pre-commit hooks"
      exit 0
    fi

    # Check if .pre-commit-config.yaml exists
    if [[ ! -f .pre-commit-config.yaml ]]; then
      log_warning "No .pre-commit-config.yaml found, skipping pre-commit hooks"
      exit 0
    fi

    # Run pre-commit hooks with timeout
    if timeout 300 ${pkgs.pre-commit}/bin/pre-commit run --all-files; then
      log_success "All pre-commit hooks passed!"
      exit 0
    else
      exit_code=$?
      if [[ $exit_code -eq 124 ]]; then
        log_error "Pre-commit hooks timed out after 5 minutes"
      else
        log_error "Pre-commit hooks failed (exit code: $exit_code)"
      fi
      log_info "Fix the issues above and try committing again"
      exit 1
    fi
  '';
in {
  # Sops configuration
  sops = {
    defaultSopsFile = ../../../../secrets/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      git-userName = {
        path = "${config.home.homeDirectory}/.config/git/username";
      };
      git-userEmail = {
        path = "${config.home.homeDirectory}/.config/git/email";
      };
      git-signingKey = {
        path = "${config.home.homeDirectory}/.config/git/signingkey";
      };
    };
  };
  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
    };
  };

  # Git configuration using sops secrets
  programs.git = {
    enable = true;
    # userName and userEmail are managed by the post-checkout/post-merge hooks
    signing = {
      signByDefault = true;
    };

    extraConfig = {
      pull.rebase = "true";
      diff.guitool = "meld";
      difftool.meld.path = "${pkgs.meld}/bin/meld";
      difftool.prompt = "false";
      merge.tool = "meld";
      mergetool.meld.path = "${pkgs.meld}/bin/meld";
      commit.gpgsign = true;
      tag.gpgsign = true;

      # Create an init template to set up git config
      init.templateDir = "${config.home.homeDirectory}/.git-template";
      # pre-commit hook
    };
  };

  # Create git template directory with hooks
  home.file = {
    ".git-template/hooks/post-checkout" = {
      source = postCheckoutHook;
      executable = true;
    };
    ".git-template/hooks/post-merge" = {
      source = postMergeHook;
      executable = true;
    };
    ".git-template/hooks/pre-commit" = {
      source = preCommitHook;
      executable = true;
    };
  };
}
