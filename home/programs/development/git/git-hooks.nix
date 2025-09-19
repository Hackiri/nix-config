{
  pkgs,
  lib,
  config,
  inputs ? {},
  ...
}: let
  # Create hook scripts that use sops secrets
  postCheckoutHook = pkgs.writeShellScript "post-checkout-hook" ''
    echo "Setting up git configuration..."
    git config user.name "$(cat ${config.sops.secrets.git-userName.path})"
    git config user.email "$(cat ${config.sops.secrets.git-userEmail.path})"
    git config user.signingkey "$(cat ${config.sops.secrets.git-signingKey.path})"
    echo "Git configuration updated from sops secrets!"
  '';

  postMergeHook = pkgs.writeShellScript "post-merge-hook" ''
    echo "Setting up git configuration..."
    git config user.name "$(cat ${config.sops.secrets.git-userName.path})"
    git config user.email "$(cat ${config.sops.secrets.git-userEmail.path})"
    git config user.signingkey "$(cat ${config.sops.secrets.git-signingKey.path})"
    echo "Git configuration updated from sops secrets!"
  '';

  preCommitHook = pkgs.writeShellScript "pre-commit-hook" ''
    echo "Running pre-commit hooks..."
    ${pkgs.pre-commit}/bin/pre-commit run --all-files
    if [ $? -ne 0 ]; then
      echo "Pre-commit hooks failed. Commit aborted."
      exit 1
    fi
    echo "Pre-commit hooks passed!"
  '';
in {
  # Sops configuration
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
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
