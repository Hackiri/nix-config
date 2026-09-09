#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'host-layout: %s\n' "$*" >&2
  exit 1
}

if grep -q 'stateVersion' home/profiles/layers/foundation.nix; then
  fail "Home Manager stateVersion remains in the shared foundation layer"
fi
if grep -Eq 'homebrew|nix-homebrew' modules/system/darwin/default.nix; then
  fail "Darwin base still selects Homebrew"
fi
if grep -Eq 'openssh|podman' modules/system/nixos/default.nix; then
  fail "NixOS base still selects OpenSSH or Podman"
fi

grep -Fq '../../modules/system/darwin/roles/workstation.nix' hosts/mbp2/configuration.nix ||
  fail "mbp2 does not select the Darwin workstation role"
grep -Fq 'system.stateVersion = 6;' hosts/mbp2/configuration.nix ||
  fail "mbp2 Darwin stateVersion changed"
grep -Fq 'stateVersion = "25.05";' hosts/mbp2/home.nix ||
  fail "mbp2 Home Manager stateVersion changed"

result="$(
  nix eval --no-update-lock-file --json .#darwinConfigurations.mbp2 --apply '
    host: let
      home = builtins.head (builtins.attrValues host.config.home-manager.users);
      packageNames = map (package: package.pname or package.name) home.home.packages;
    in {
      homebrew = host.config.homebrew.enable;
      nixHomebrew = host.config.nix-homebrew.enable;
      darwinStateVersion = host.config.system.stateVersion;
      homeStateVersion = home.home.stateVersion;
      workstationPrograms = builtins.all (enabled: enabled) [
        home.programs.git.enable
        home.programs.neovim.enable
        home.programs.tmux.enable
        home.programs.zsh.enable
      ];
      missingKubernetesPackages = builtins.filter (name: !(builtins.elem name packageNames)) [
        "kubectl"
        "kubernetes-helm"
        "k9s"
        "kubeconform"
      ];
      forbiddenLinuxPackages = builtins.filter (name: builtins.elem name packageNames) [
        "xclip"
        "xsel"
      ];
      kubeEditor = home.home.sessionVariables.KUBE_EDITOR;
    }
  '
)"
[[ $result == '{"darwinStateVersion":6,"forbiddenLinuxPackages":[],"homeStateVersion":"25.05","homebrew":true,"kubeEditor":"nvim","missingKubernetesPackages":[],"nixHomebrew":true,"workstationPrograms":true}' ]] ||
  fail "mbp2 workstation behavior changed: $result"

grep -Fq 'stateVersion = "26.05";' templates/host/home.nix ||
  fail "templates/host/home.nix does not use Home Manager 26.05"
grep -Fq 'home.stateVersion = "26.05";' templates/nixos-desktop/home.nix ||
  fail "templates/nixos-desktop/home.nix does not use Home Manager 26.05"
grep -Fq 'system.stateVersion = 7;' templates/host/configuration.nix ||
  fail "new Darwin host template does not use stateVersion 7"
grep -Fq 'system.stateVersion = "26.05";' templates/nixos-desktop/configuration.nix ||
  fail "NixOS desktop template does not use stateVersion 26.05"

printf 'host-layout: ok\n'
