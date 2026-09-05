# Language-specific development shells and their composition entry point.
# Usage: nix develop .#node, nix develop .#python, etc.
{
  pkgs,
  shellNames ? null,
}: let
  packageSets = with pkgs; {
    node = [
      nodejs
      yarn
      pnpm
      bun
      typescript
      prettier
    ];
    python = [
      python314
      uv
      python314Packages.pip
      python314Packages.ruff
      python314Packages.mypy
      python314Packages.pytest
      python314Packages.pyyaml
      python314Packages.python-dotenv
    ];
    rust = [
      rustc
      cargo
      rustfmt
      rust-analyzer
      clippy
    ];
    go = [
      go
      gopls
      golangci-lint
      delve
    ];
    ruby = [
      ruby_3_4
    ];
    php = [
      php84
      php84Packages.composer
    ];
  };

  shellHooks = {
    node = ''echo "Node.js $(node --version) dev environment"'';
    python = ''echo "Python $(python3 --version) dev environment"'';
    rust = ''echo "Rust $(rustc --version) dev environment"'';
    go = ''echo "Go $(go version) dev environment"'';
    ruby = ''echo "Ruby $(ruby --version) dev environment"'';
    php = ''echo "PHP $(php --version | head -1) dev environment"'';
  };

  unknownShells =
    if shellNames == null
    then []
    else builtins.filter (name: !(builtins.hasAttr name packageSets)) shellNames;

  languageShells =
    builtins.mapAttrs (
      name: packages:
        pkgs.mkShell {
          inherit packages;
          shellHook = shellHooks.${name};
        }
    )
    packageSets;
in
  if shellNames == null
  then languageShells
  else
    assert pkgs.lib.assertMsg (unknownShells == [])
    "unknown development shell(s): ${builtins.concatStringsSep ", " unknownShells}";
      pkgs.mkShell {
        packages = pkgs.lib.unique (builtins.concatMap (name: packageSets.${name}) shellNames);
        shellHook = builtins.concatStringsSep "\n" (map (name: shellHooks.${name}) shellNames);
      }
