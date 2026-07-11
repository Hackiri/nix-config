#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'semantic-config: %s\n' "$*" >&2
  exit 1
}

# Nix interpolation must stay literal inside the --apply expression.
# shellcheck disable=SC2016
result="$(
  nix eval --raw --no-update-lock-file .#darwinConfigurations --apply '
    configurations:
    let
      hostSpecs = [
        { name = "mbp"; system = "x86_64-darwin"; }
        { name = "mbp2"; system = "aarch64-darwin"; }
      ];
      expectedNames = map (spec: spec.name) hostSpecs;
      actualNames = builtins.attrNames configurations;
      requiredPackages = [ "kubectl" "kubernetes-helm" "k9s" "kubeconform" ];
      forbiddenPackages = [ "xclip" "xsel" ];
      checkHost = spec:
        let
          host = configurations.${spec.name};
          home = host.config.home-manager.users.wm;
          packageNames = map (package: package.pname or package.name) home.home.packages;
          missingPackages = builtins.filter (name: ! builtins.elem name packageNames) requiredPackages;
          forbiddenPresent = builtins.filter (name: builtins.elem name packageNames) forbiddenPackages;
          enabledPrograms = [
            home.programs.git.enable
            home.programs.neovim.enable
            home.programs.tmux.enable
            home.programs.zsh.enable
          ];
          drvPath = builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath;
        in
        if host.pkgs.stdenv.hostPlatform.system != spec.system then
          throw "${spec.name}: expected ${spec.system}, got ${host.pkgs.stdenv.hostPlatform.system}"
        else if !(builtins.all (enabled: enabled) enabledPrograms) then
          throw "${spec.name}: required workstation programs are not all enabled"
        else if missingPackages != [ ] then
          throw "${spec.name}: missing capability packages: ${builtins.concatStringsSep ", " missingPackages}"
        else if forbiddenPresent != [ ] then
          throw "${spec.name}: contains non-Darwin packages: ${builtins.concatStringsSep ", " forbiddenPresent}"
        else if home.home.sessionVariables.KUBE_EDITOR != "nvim" then
          throw "${spec.name}: expected KUBE_EDITOR=nvim"
        else
          builtins.seq drvPath true;
    in
    if actualNames != expectedNames then
      throw "expected Darwin hosts ${builtins.concatStringsSep ", " expectedNames}; got ${builtins.concatStringsSep ", " actualNames}"
    else if builtins.all checkHost hostSpecs then
      "ok"
    else
      throw "semantic host validation failed"
  '
)"

[[ $result == "ok" ]] || fail "unexpected evaluation result: $result"
printf 'semantic-config: ok\n'
