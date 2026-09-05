# SOPS secrets for this host.
#
# The imported capability provides the machinery (sops-nix wiring, age key
# location, git post-checkout/post-merge hooks, shell aliases) plus the three
# git secrets those hooks require:
#
#   git-userName             -> ~/.config/git/username
#   git-userEmail            -> ~/.config/git/email
#   git-signingKey-<host>    -> ~/.config/git/signingkey
#
# Everything else is declared here, so adding or removing a secret is a
# host-local edit.
#
# How to add a value:
#   1. Add the entry to the encrypted store:
#        sops secrets/secrets.yaml
#      (key name must match the attribute name used below)
#   2. Declare it in `sops.secrets` below with the path it should decrypt to.
#   3. Rebuild:  sudo darwin-rebuild switch --flake .#mbp2
#   4. Validate structure without decrypting values:  just check
#
# `path` is where sops-nix writes the decrypted value; `mode` is its file
# permission (0400 read-only, 0600 read/write for files tools may rewrite).
{config, ...}: {
  imports = [
    ../../home/profiles/capabilities/sops.nix
  ];

  config.sops.secrets = {
    # SSH config fragment included by ~/.ssh/config
    ssh-config-srv696730 = {
      path = "${config.home.homeDirectory}/.ssh/conf.d/srv696730";
      mode = "0600";
    };

    # Examples — uncomment and add the matching key to secrets/secrets.yaml.
    #
    # API token read by shells or program configs:
    # github-token = {
    #   path = "${config.home.homeDirectory}/.config/secrets/github-token";
    #   mode = "0400";
    # };
    #
    # SSH private key:
    # ssh-key-personal = {
    #   path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    #   mode = "0600";
    # };
  };
}
