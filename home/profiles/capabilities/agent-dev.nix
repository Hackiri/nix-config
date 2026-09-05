# LLM agent development workflow capability
# Purpose: provider-neutral local tools for AI-assisted development.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/agent-dev.nix ];
{
  config,
  hostName,
  hostInventory,
  lib,
  pkgs,
  ...
}: let
  hostTargets = map (host: {
    inherit (host) name;
    output = host.configuration;
  }) (builtins.attrValues hostInventory);
  evalHostCalls =
    lib.concatMapStrings (host: ''
      eval_host ${lib.escapeShellArg host.output} ${lib.escapeShellArg host.name}
    '')
    hostTargets;
  hostOutputCases =
    lib.concatMapStrings (host: ''
      ${lib.escapeShellArg host.name}) configuration_set=${lib.escapeShellArg host.output} ;;
    '')
    hostTargets;

  copyAgentEvalSource = pkgs.writeText "copy-agent-eval-source.py" ''
    import os
    import shutil
    import stat
    import sys

    repo_root, destination, list_path = sys.argv[1:]
    with open(list_path, "rb") as source_list:
        relative_paths = [
            os.fsdecode(path)
            for path in source_list.read().split(b"\0")
            if path
        ]
    allowed_paths = set(relative_paths)
    root_fd = os.open(repo_root, os.O_RDONLY | os.O_DIRECTORY)

    def fail(message, path):
        raise SystemExit("agent-guard: %s: %r" % (message, path))

    try:
        for relative_path in relative_paths:
            if os.path.isabs(relative_path):
                fail("absolute evaluation-source path", relative_path)
            parts = relative_path.split("/")
            if not parts or any(part in ("", ".", "..") for part in parts):
                fail("unsafe evaluation-source path", relative_path)

            parent_fd = os.dup(root_fd)
            try:
                missing = False
                for part in parts[:-1]:
                    try:
                        next_fd = os.open(
                            part,
                            os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                            dir_fd=parent_fd,
                        )
                    except FileNotFoundError:
                        missing = True
                        break
                    except OSError:
                        fail("unsafe evaluation-source ancestor", relative_path)
                    os.close(parent_fd)
                    parent_fd = next_fd
                if missing:
                    continue

                name = parts[-1]
                try:
                    source_stat = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
                except FileNotFoundError:
                    continue

                destination_path = os.path.join(destination, *parts)
                os.makedirs(os.path.dirname(destination_path), exist_ok=True)
                if stat.S_ISREG(source_stat.st_mode):
                    source_fd = os.open(
                        name,
                        os.O_RDONLY | os.O_NOFOLLOW,
                        dir_fd=parent_fd,
                    )
                    with os.fdopen(source_fd, "rb") as source, open(destination_path, "xb") as target:
                        shutil.copyfileobj(source, target)
                    os.chmod(destination_path, stat.S_IMODE(source_stat.st_mode) & 0o777)
                elif stat.S_ISLNK(source_stat.st_mode):
                    target = os.readlink(name, dir_fd=parent_fd)
                    if os.path.isabs(target):
                        fail("absolute evaluation-source symlink", relative_path)
                    target_path = os.path.normpath(os.path.join(os.path.dirname(relative_path), target))
                    if target_path == ".." or target_path.startswith("../") or target_path not in allowed_paths:
                        fail("evaluation-source symlink leaves the selected files", relative_path)
                    os.symlink(target, destination_path)
                else:
                    fail("unsupported evaluation-source file type", relative_path)
            finally:
                os.close(parent_fd)
    finally:
        os.close(root_fd)
  '';

  agentGuard = pkgs.writeShellScriptBin "agent-guard" ''
    set -euo pipefail

    default_base=${lib.escapeShellArg "HEAD"}
    base_ref="''${1:-$default_base}"
    repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
    cd "$repo_root"

    if ! base_commit="$(${pkgs.git}/bin/git rev-parse --verify --end-of-options "$base_ref^{commit}" 2>/dev/null)"; then
      printf 'agent-guard: invalid base ref: %q\n' "$base_ref" >&2
      exit 2
    fi

    changed_files_file="$(${pkgs.coreutils}/bin/mktemp)"
    trap '${pkgs.coreutils}/bin/rm -f "$changed_files_file"' EXIT
    if ! {
      ${pkgs.git}/bin/git diff --name-only -z --no-renames "$base_commit" -- &&
        ${pkgs.git}/bin/git ls-files -z --others --exclude-standard
    } | ${pkgs.coreutils}/bin/sort -zu >"$changed_files_file"; then
      echo "agent-guard: changed-file discovery failed" >&2
      exit 2
    fi
    mapfile -d "" -t changed_files <"$changed_files_file"
    ${pkgs.coreutils}/bin/rm -f "$changed_files_file"
    trap - EXIT

    if (( ''${#changed_files[@]} == 0 )); then
      echo "agent-guard: no changed files"
      exit 0
    fi

    blocked_regex='(^secrets/|^\.sops\.yaml$|(^|/)id_[a-z0-9_]+$|(^|/)\.env($|\.))'
    blocked_files=()
    nix_files=()
    evaluate_hosts=0
    for file in "''${changed_files[@]}"; do
      if [[ "$file" =~ $blocked_regex ]]; then
        blocked_files+=("$file")
      fi
      if [[ "$file" == *.nix && -e "$file" ]]; then
        nix_files+=("$file")
      fi
      if [[ "$file" =~ ^(flake\.nix|home/|hosts/|modules/|lib/|pkgs/) ]]; then
        evaluate_hosts=1
      fi
    done

    if (( ''${#blocked_files[@]} > 0 )); then
      echo "agent-guard: blocked secret-sensitive path changed:" >&2
      printf '  %q\n' "''${blocked_files[@]}" >&2
      exit 1
    fi

    for file in "''${changed_files[@]}"; do
      if [[ "$file" == "flake.lock" && "''${ALLOW_FLAKE_LOCK:-0}" != "1" ]]; then
        echo "agent-guard: flake.lock changed; rerun with ALLOW_FLAKE_LOCK=1 only when intentional" >&2
        exit 1
      fi
    done

    if (( ''${#nix_files[@]} > 0 )); then
      echo "agent-guard: checking changed Nix files"
      ${pkgs.alejandra}/bin/alejandra --check -- "''${nix_files[@]}"
      ${pkgs.deadnix}/bin/deadnix --fail -- "''${nix_files[@]}"
      ${pkgs.statix}/bin/statix check .
    fi

    eval_source=""
    source_list_file=""
    cleanup_eval_source() {
      [[ -z "$eval_source" ]] || ${pkgs.coreutils}/bin/rm -rf "$eval_source"
      [[ -z "$source_list_file" ]] || ${pkgs.coreutils}/bin/rm -f "$source_list_file"
    }
    prepare_eval_source() {
      eval_source="$(${pkgs.coreutils}/bin/mktemp -d)"
      source_list_file="$(${pkgs.coreutils}/bin/mktemp)"
      trap cleanup_eval_source EXIT

      if ! ${pkgs.git}/bin/git ls-files -z --cached --others --exclude-standard >"$source_list_file"; then
        echo "agent-guard: evaluation-source discovery failed" >&2
        exit 2
      fi

      if ! ${pkgs.python3}/bin/python3 ${copyAgentEvalSource} \
        "$repo_root" "$eval_source" "$source_list_file"; then
        echo "agent-guard: evaluation-source copy failed" >&2
        exit 2
      fi

      ${pkgs.coreutils}/bin/rm -f "$source_list_file"
      source_list_file=""
    }

    eval_host() {
      local configuration_set="$1"
      local host="$2"
      if [[ -z "$eval_source" ]]; then
        prepare_eval_source
      fi
      (
        cd "$eval_source"
        ${pkgs.nix}/bin/nix eval --raw --no-update-lock-file \
          "path:.#''${configuration_set}.''${host}.config.system.build.toplevel.drvPath" >/dev/null
      )
    }

    if (( evaluate_hosts )); then
      echo "agent-guard: evaluating configured hosts"
      ${evalHostCalls}
    fi

    echo "agent-guard: ok"
  '';

  agentEvalHost = pkgs.writeShellScriptBin "agent-eval-host" ''
    set -euo pipefail

    host="''${1:-${hostName}}"
    repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
    cd "$repo_root"
    case "$host" in
      ${hostOutputCases}
      *)
        echo "agent-eval-host: unknown host '$host'" >&2
        exit 2
        ;;
    esac
    ${pkgs.nix}/bin/nix eval --raw --no-update-lock-file \
      "path:.#''${configuration_set}.''${host}.config.system.build.toplevel.drvPath"
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
