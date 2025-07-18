{
  pkgs,
  lib,
  config,
  inputs ? {},
  ...
}: let
  # Import secrets if the file exists, otherwise use placeholder values
  secrets =
    if builtins.pathExists /secrets/secrets.nix
    then let
      imported = import /secrets/secrets.nix;
      # Debug output to verify the import
      _ = builtins.trace "Imported GPG key: ${imported.git.signingKey}" null;
    in
      imported
    else {
      git = {
        userName = "user";
        userEmail = "user@example.com";
        signingKey = "";
      };
    };

  # Create hook scripts
  postCheckoutHook = pkgs.writeShellScript "post-checkout-hook" ''
    echo "Setting up git configuration..."
    git config user.name "${secrets.git.userName}"
    git config user.email "${secrets.git.userEmail}"
    git config user.signingkey "${secrets.git.signingKey}"
    echo "Git configuration updated!"
  '';

  postMergeHook = pkgs.writeShellScript "post-merge-hook" ''
    echo "Setting up git configuration..."
    git config user.name "${secrets.git.userName}"
    git config user.email "${secrets.git.userEmail}"
    git config user.signingkey "${secrets.git.signingKey}"
    echo "Git configuration updated!"
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
  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;

    # Git-crypt is installed as a package, not as a git setting
    # We'll add it to the packages list below

    inherit (secrets.git) userName userEmail;

    signing = {
      signByDefault = true;
      key = "${secrets.git.signingKey}"; # Explicitly use string interpolation to ensure value is set
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
      init.templateDir = "~/.git-template";
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
