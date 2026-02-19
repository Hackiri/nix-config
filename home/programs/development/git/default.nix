# Basic Git configuration without sops-nix integration
# Use this for a simple Git setup without encrypted secrets.
# For sops-integrated Git with hooks, use home/profiles/features/sops.nix instead.
{
  lib,
  pkgs,
  ...
}: {
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
      signByDefault = lib.mkDefault false;
    };

    settings = {
      pull.rebase = "true";
      diff.guitool = "meld";
      difftool.meld.path = "${pkgs.meld}/bin/meld";
      difftool.prompt = "false";
      merge.tool = "meld";
      mergetool.meld.path = "${pkgs.meld}/bin/meld";

      # Delta integration for better terminal diffs
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
