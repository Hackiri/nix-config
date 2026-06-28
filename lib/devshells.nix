# Language-specific development shells
# Usage: nix develop .#node, nix develop .#python, etc.
{pkgs}: {
  node = pkgs.mkShell {
    packages = with pkgs; [
      nodejs
      yarn
      pnpm
      bun
      typescript
      prettier
    ];
    shellHook = ''
      echo "Node.js $(node --version) dev environment"
    '';
  };

  python = pkgs.mkShell {
    packages = with pkgs; [
      python314
      uv
      python314Packages.pip
      python314Packages.ruff
      python314Packages.mypy
      python314Packages.pytest
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
      rust-analyzer
      clippy
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

  ruby = pkgs.mkShell {
    packages = with pkgs; [
      ruby_3_4
    ];
    shellHook = ''
      echo "Ruby $(ruby --version) dev environment"
    '';
  };

  php = pkgs.mkShell {
    packages = with pkgs; [
      php84
      php84Packages.composer
    ];
    shellHook = ''
      echo "PHP $(php --version | head -1) dev environment"
    '';
  };
}
