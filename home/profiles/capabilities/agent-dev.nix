# LLM agent development workflow capability
# Purpose: provider-neutral local tools for AI-assisted development.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/agent-dev.nix ];
{
  config,
  hostName,
  lib,
  pkgs,
  ...
}: let
  # Auto-discover Darwin hosts from the hosts/ directory
  hostNames = builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../../hosts));
  darwinHosts = builtins.filter (name: (import (../../../hosts + "/${name}/meta.nix")).type == "darwin") hostNames;
  evalHosts = lib.concatMapStringsSep " " lib.escapeShellArg darwinHosts;

  agentGuard = pkgs.writeShellScriptBin "agent-guard" ''
    set -euo pipefail

    default_base=${lib.escapeShellArg "HEAD"}
    base_ref="''${1:-$default_base}"
    repo_root="$(git rev-parse --show-toplevel)"
    cd "$repo_root"

    changed_files="$(
      {
        git diff --name-only --diff-filter=ACMRT "$base_ref" -- 2>/dev/null || true
        git ls-files --others --exclude-standard
      } | sort -u
    )"

    if [[ -z "$changed_files" ]]; then
      echo "agent-guard: no changed files"
      exit 0
    fi

    blocked_regex='(^secrets/|^\.sops\.yaml$|(^|/)id_[a-z0-9_]+$|(^|/)\.env($|\.))'
    if grep -E "$blocked_regex" <<<"$changed_files" >/dev/null; then
      echo "agent-guard: blocked secret-sensitive path changed:" >&2
      grep -E "$blocked_regex" <<<"$changed_files" >&2
      exit 1
    fi

    if grep -Fx "flake.lock" <<<"$changed_files" >/dev/null && [[ "''${ALLOW_FLAKE_LOCK:-0}" != "1" ]]; then
      echo "agent-guard: flake.lock changed; rerun with ALLOW_FLAKE_LOCK=1 only when intentional" >&2
      exit 1
    fi

    nix_files="$(grep -E '\.nix$' <<<"$changed_files" || true)"
    if [[ -n "$nix_files" ]]; then
      echo "agent-guard: checking changed Nix files"
      ${pkgs.alejandra}/bin/alejandra --check $nix_files
      ${pkgs.deadnix}/bin/deadnix --fail $nix_files
      ${pkgs.statix}/bin/statix check .
    fi

    if grep -E '^(flake\.nix|home/|hosts/|modules/|lib/|pkgs/)' <<<"$changed_files" >/dev/null; then
      echo "agent-guard: evaluating configured hosts"
      for host in ${evalHosts}; do
        ${pkgs.nix}/bin/nix eval --impure --raw --expr "let flake = builtins.getFlake \"git+file://$repo_root\"; in flake.darwinConfigurations.$host.config.system.build.toplevel.drvPath" >/dev/null
      done
    fi

    echo "agent-guard: ok"
  '';

  agentEvalHost = pkgs.writeShellScriptBin "agent-eval-host" ''
    set -euo pipefail

    host="''${1:-${hostName}}"
    repo_root="$(git rev-parse --show-toplevel)"
    ${pkgs.nix}/bin/nix eval --impure --raw --expr "let flake = builtins.getFlake \"git+file://$repo_root\"; in flake.darwinConfigurations.$host.config.system.build.toplevel.drvPath"
  '';
in {
  config = {
    home.packages =
      [
        agentGuard
        agentEvalHost
      ]
      ++ (with pkgs; [
        # Shared runtimes and language intelligence used by LLM agent hooks,
        # plugins and subprocesses, regardless of the agent provider.
        nodejs
        pyright
        lua-language-server
        rust-analyzer

        # Repository inspection and validation tools.
        ripgrep
        fd
        git
        gh
        shellcheck
        yq-go

        # Nix and general development workflow tools.
        alejandra
        deadnix
        statix
        just
        jq
        uv
      ]);

    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      ai-guard = "agent-guard";
      ai-guard-lock = "ALLOW_FLAKE_LOCK=1 agent-guard";
      ai-eval-host = "agent-eval-host";
      ai-template-check = "nix flake check --no-build";
    };

    programs.bash.shellAliases = lib.mkIf config.programs.bash.enable {
      ai-guard = "agent-guard";
      ai-guard-lock = "ALLOW_FLAKE_LOCK=1 agent-guard";
      ai-eval-host = "agent-eval-host";
      ai-template-check = "nix flake check --no-build";
    };
  };
}
