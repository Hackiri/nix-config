# Language-specific development shells
# Usage: nix develop .#node, nix develop .#python, etc.
{pkgs}: {
  node = pkgs.mkShell {
    packages = with pkgs; [
      nodejs
      yarn
      pnpm
      bun
      nodePackages.typescript
      nodePackages.prettier
    ];
    shellHook = ''
      echo "Node.js $(node --version) dev environment"
    '';
  };

  python = pkgs.mkShell {
    packages = with pkgs; [
      python313
      uv
      python313Packages.pip
      python313Packages.ruff
      python313Packages.mypy
      python313Packages.pytest
    ];
    shellHook = ''
      echo "Python $(python3 --version) dev environment"
    '';
  };

  rust = pkgs.mkShell {
    packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ];
    shellHook = ''
      echo "Rust $(rustc --version) dev environment"
    '';
  };

  go = pkgs.mkShell {
    packages = with pkgs; [
      go
      gopls
      golangci-lint
      delve
    ];
    shellHook = ''
      echo "Go $(go version) dev environment"
    '';
  };
}
