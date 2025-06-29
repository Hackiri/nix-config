{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "devshell";
  version = "1.0.0";
  
  src = ./.;
  
  buildInputs = with pkgs; [
    bash
    coreutils
    python3
    go
    nodejs
    rustc
    cargo
    git
    nix
    just
    lazygit
    bottom
    zoxide
    helix
    bat
    less
  ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp devshell.sh $out/bin/devshell
    chmod +x $out/bin/devshell
  '';
  
  meta = {
    description = "Development shell environment launcher";
    mainProgram = "devshell";
  };
}
