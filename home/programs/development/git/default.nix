# Basic Git configuration without sops-nix integration
# Use this for a simple Git setup without encrypted secrets.
# For sops-integrated Git with hooks, use git-hooks.nix instead.
{pkgs, ...}: {
  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
    };
  };

  # Basic Git configuration
  programs.git = {
    enable = true;

    # Configure these directly or leave them for git config --global
    # userName = "Your Name";
    # userEmail = "your-email@example.com";

    signing = {
      signByDefault = true;
      # key = "YOUR_GPG_KEY_ID";
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
    };
  };
}
