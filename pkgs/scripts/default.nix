# Collection of utility scripts
{pkgs ? import <nixpkgs> {}}: {
  # Development tools helper
  dev-tools = import ../dev-tools.nix {inherit pkgs;};

  # Add more scripts here
  # backup-script = import ./backup.nix {inherit pkgs;};
  # deploy-script = import ./deploy.nix {inherit pkgs;};
}
