{
  pkgs,
  lib,
  config,
  inputs ? {},
  ...
}: let
  # Import secrets if the file exists, otherwise use placeholder values
  secrets =
    if builtins.pathExists ./secrets.nix
    then 
      let 
        imported = import ./secrets.nix;
        # Debug output to verify the import
        _ = builtins.trace "Imported GPG key: ${imported.git.signingKey}" null;
      in imported
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

in {
  # Git configuration
  programs.git = {
    enable = true;
    inherit (secrets.git) userName userEmail;
    signing = {
      signByDefault = true;
      key = secrets.git.signingKey;
    };
    extraConfig = {
      commit.gpgsign = true;
      tag.gpgsign = true;
      # Explicitly set user.name, user.email, and user.signingkey
      # This ensures these values are set in the git config
      user = {
        name = secrets.git.userName;
        email = secrets.git.userEmail;
        signingkey = secrets.git.signingKey;
      };
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
  };
}
