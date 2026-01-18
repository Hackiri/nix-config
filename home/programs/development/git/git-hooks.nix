{
  pkgs,
  config,
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
      log_info "Signing key: $signingkey"
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
  # Note: pre-commit hooks are now managed by git-hooks.nix in flake.nix
  home.file = {
    ".git-template/hooks/post-checkout" = {
      source = postCheckoutHook;
      executable = true;
    };
    ".git-template/hooks/post-merge" = {
      source = postMergeHook;
      executable = true;
    };
  };
}
