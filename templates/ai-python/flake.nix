{
  description = "Python AI application environment with uv and evals";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            python314
            uv
            just
            jq
            git
          ];
          shellHook = ''
            echo "AI Python $(python3 --version) dev environment"
            echo "Run: uv sync && just test"
          '';
        };
      }
    );
  };
}
