# Agent Dev Profile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional `profiles.agentDev` Home Manager capability so AI engineering tools, Hermes Agent, guardrails, and helper commands can be enabled or disabled per host.

**Architecture:** Put local agent workflow tools in `home/profiles/capabilities/agent-dev.nix`, gated by `profiles.agentDev.enable`. Keep project templates and docs as inert repository assets because they do not affect host activation. Hosts opt in by importing the capability and setting `profiles.agentDev.enable = true`.

**Tech Stack:** Nix flakes, Home Manager module system, just, direnv, uv, Python 3.13, OpenAI Python SDK, MCP Launchpad, shell scripts

---

## Files To Create

- `home/profiles/capabilities/agent-dev.nix`: optional Home Manager capability for agent development workflows.
- `docs/workflows/ai-agent-workflows.md`: operating guide for agents, subagents, MCP, and review loops.
- `docs/workflows/mcp-curation.md`: MCP discovery and allowlist workflow using `mcpl`.
- `templates/ai-python/flake.nix`: reproducible Python AI app dev shell.
- `templates/ai-python/.envrc`: direnv entrypoint for the template.
- `templates/ai-python/.gitignore`: excludes secrets, caches, and eval output.
- `templates/ai-python/pyproject.toml`: uv-managed Python package metadata.
- `templates/ai-python/justfile`: setup, test, lint, eval commands.
- `templates/ai-python/evals/cases.jsonl`: starter golden eval cases.
- `templates/ai-python/evals/run_eval.py`: minimal OpenAI Responses API eval runner.
- `templates/ai-python/src/ai_app/__init__.py`: package marker.

## Files To Modify

- `hosts/mbp2/home.nix`: import and enable the `agentDev` capability.
- `hosts/mbp/home.nix`: import the `agentDev` capability and leave it disabled unless desired.
- `hosts/mbp2/configuration.nix`: remove direct Hermes Agent system service wiring.
- `hosts/mbp/configuration.nix`: remove direct Hermes Agent system service wiring.
- `modules/services/darwin/hermes-agent-package.nix`: delete after functionality moves into `agent-dev.nix`.
- `templates/host/configuration.nix`: remove the Darwin Hermes service-module example.
- `home/profiles/README.md`: document the new optional profile.
- `flake.nix`: register `templates.ai-python`.
- `README.md`: link the agent profile, workflow docs, and template.

---

### Task 1: Add Agent Dev Capability

**Files:**
- Create: `home/profiles/capabilities/agent-dev.nix`

- [ ] **Step 1: Create the Home Manager module**

```nix
# Agent development workflow capability
# Purpose: optional local tools for AI-assisted development.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/agent-dev.nix ];
#   profiles.agentDev.enable = true;
{
  config,
  hostName,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.agentDev;
  inherit (pkgs.stdenv.hostPlatform) system;
  hermesPackages = inputs.hermes-agent.packages.${system} or {};
  hermesPackageAvailable = hermesPackages ? default;
  evalHosts = lib.concatMapStringsSep " " lib.escapeShellArg cfg.evaluateHosts;

  agentGuard = pkgs.writeShellScriptBin "agent-guard" ''
    set -euo pipefail

    default_base=${lib.escapeShellArg cfg.defaultBaseRef}
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
  options.profiles.agentDev = with lib; {
    enable = mkEnableOption "AI agent development workflow";

    defaultBaseRef = mkOption {
      type = types.str;
      default = "HEAD";
      description = "Default Git ref used by agent-guard when no base ref is provided.";
    };

    evaluateHosts = mkOption {
      type = types.listOf types.str;
      default = ["mbp2" "mbp"];
      description = "Darwin host outputs evaluated by agent-guard when Nix-owned files change.";
    };

    hermes.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install Hermes Agent from the flake input when available for this host platform.";
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optionals (cfg.hermes.enable && !hermesPackageAvailable) [
      "profiles.agentDev.hermes.enable is true but hermes-agent has no package for ${system}; Hermes Agent will not be installed"
    ];

    home.packages = [
      agentGuard
      agentEvalHost
    ] ++ lib.optionals (cfg.hermes.enable && hermesPackageAvailable) [
      hermesPackages.default
    ] ++ (with pkgs; [
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
```

- [ ] **Step 2: Format and lint the new module**

Run:

```bash
alejandra home/profiles/capabilities/agent-dev.nix
deadnix home/profiles/capabilities/agent-dev.nix
statix check home/profiles/capabilities/agent-dev.nix
```

Expected: all commands exit 0.

- [ ] **Step 3: Commit**

```bash
git add home/profiles/capabilities/agent-dev.nix
git commit -m "feat(home): add optional agent dev profile"
```

---

### Task 2: Enable The Profile Per Host

**Files:**
- Modify: `hosts/mbp2/home.nix`
- Modify: `hosts/mbp/home.nix`
- Modify: `hosts/mbp2/configuration.nix`
- Modify: `hosts/mbp/configuration.nix`
- Modify: `templates/host/configuration.nix`
- Delete: `modules/services/darwin/hermes-agent-package.nix`

- [ ] **Step 1: Import the capability in both Darwin hosts**

Add this import beside the other capabilities:

```nix
    ../../home/profiles/capabilities/agent-dev.nix # Optional AI agent development workflow
```

- [ ] **Step 2: Enable it on `mbp2`**

Add this under `profiles = { ... };` in `hosts/mbp2/home.nix`:

```nix
    # AI agent development workflow
    agentDev = {
      enable = true;
      hermes.enable = true;
      evaluateHosts = ["mbp2" "mbp"];
    };
```

- [ ] **Step 3: Leave `mbp` disabled but documented**

Add this under `profiles = { ... };` in `hosts/mbp/home.nix`:

```nix
    # Disabled on this host; set true to install agent workflow tools.
    agentDev.enable = false;
```

- [ ] **Step 4: Remove direct Darwin system Hermes wiring**

In `hosts/mbp2/configuration.nix`, remove this import:

```nix
    ../../modules/services/darwin/hermes-agent-package.nix
```

Remove this setting:

```nix
  services.hermes-agent.enable = true;
```

In `hosts/mbp/configuration.nix`, remove this import:

```nix
    ../../modules/services/darwin/hermes-agent-package.nix
```

Remove this setting and its comment:

```nix
  # Hermes has no x86_64-darwin package, so keep this host explicit and quiet.
  services.hermes-agent.enable = pkgs.stdenv.hostPlatform.system != "x86_64-darwin";
```

- [ ] **Step 5: Delete the obsolete Darwin Hermes module**

Run:

```bash
git rm modules/services/darwin/hermes-agent-package.nix
```

Expected: file removed from Git. Keep `modules/services/nixos/hermes-agent.nix` unchanged.

- [ ] **Step 6: Remove the old Darwin template hint**

In `templates/host/configuration.nix`, delete this comment:

```nix
    # Add host-specific service modules here, e.g.:
    # ../../modules/services/darwin/hermes-agent-package.nix
```

Leave the NixOS service-module example unchanged.

- [ ] **Step 7: Verify the profile toggles packages**

Run:

```bash
nix eval --impure --json --expr 'let flake = builtins.getFlake "git+file:///Users/wm/nix-config"; in builtins.elem "agent-guard" (map (pkg: pkg.name or "") flake.darwinConfigurations.mbp2.config.home-manager.users.wm.home.packages)'
```

Expected:

```json
true
```

Run:

```bash
nix eval --impure --json --expr 'let flake = builtins.getFlake "git+file:///Users/wm/nix-config"; in flake.darwinConfigurations.mbp.config.home-manager.users.wm.profiles.agentDev.enable'
```

Expected:

```json
false
```

- [ ] **Step 8: Verify Hermes is installed only through the enabled profile**

Run:

```bash
nix eval --impure --json --expr 'let flake = builtins.getFlake "git+file:///Users/wm/nix-config"; names = map (pkg: pkg.name or "") flake.darwinConfigurations.mbp2.config.home-manager.users.wm.home.packages; in builtins.any (name: builtins.match "hermes-agent.*" name != null) names'
```

Expected:

```json
true
```

Run:

```bash
rg -n "services\\.hermes-agent|hermes-agent-package" hosts modules/services/darwin templates/host
```

Expected: no output.

- [ ] **Step 9: Commit**

```bash
git add hosts/mbp2/home.nix hosts/mbp/home.nix hosts/mbp2/configuration.nix hosts/mbp/configuration.nix templates/host/configuration.nix
git commit -m "feat(home): move Hermes Agent into agent dev profile"
```

---

### Task 3: Document The Profile

**Files:**
- Modify: `home/profiles/README.md`
- Create: `docs/workflows/ai-agent-workflows.md`
- Create: `docs/workflows/mcp-curation.md`

- [ ] **Step 1: Update `home/profiles/README.md`**

Add `agent-dev.nix` to the capabilities tree and optional module list:

```text
│   ├── agent-dev.nix       # optional AI agent development workflow
```

Add this section before `capabilities/kubernetes.nix`:

```markdown
### `capabilities/agent-dev.nix`

Provides optional AI agent workflow tooling controlled by:

- `profiles.agentDev.enable`
- `profiles.agentDev.defaultBaseRef`
- `profiles.agentDev.evaluateHosts`
- `profiles.agentDev.hermes.enable`
```

- [ ] **Step 2: Create `docs/workflows/ai-agent-workflows.md`**

````markdown
# AI Agent Workflows

## Enabling The Profile

Import `home/profiles/capabilities/agent-dev.nix` in a host and set:

```nix
profiles.agentDev.enable = true;
```

## Default Loop

1. Start with `git status --short`.
2. Inspect the relevant module or template before editing.
3. Make the smallest coherent change.
4. Run `ai-guard` before claiming the change is ready.
5. Run `nix flake check --no-build` before merging host or template changes.

## Subagent Use

Use subagents for independent read-only investigation, code review, test gap analysis, and CI log triage. Keep tightly coupled implementation in the main session unless files can be split cleanly by ownership.

## Guardrails

`agent-guard` blocks secret-sensitive paths, unexpected lockfile churn, and unvalidated Nix edits. Use `ALLOW_FLAKE_LOCK=1 agent-guard` or the `ai-guard-lock` alias only when the task is explicitly updating flake inputs.

## AI App Evals

New AI app projects should start from `nix flake init -t ~/nix-config#ai-python`. Add cases to `evals/cases.jsonl`, run `just eval`, and commit eval cases with behavior changes.
````

- [ ] **Step 3: Create `docs/workflows/mcp-curation.md`**

````markdown
# MCP Curation

## Discovery

Always discover tools before calling them:

```bash
mcpl search "github pull request"
mcpl inspect github search_prs --example
```

## Recommended MCPs

- OpenAI docs: use for OpenAI API, model, Agents SDK, and Codex questions.
- GitHub: use for issues, pull requests, diffs, and Actions logs.
- Playwright/browser: use for local UI testing and screenshots.
- Sentry/Linear/Slack: add only when the project actively uses those services.

## Safety Rules

- Do not add broad MCPs by default.
- Do not store API tokens in the repo.
- Prefer read-only tool use until a task explicitly requires mutation.
- Keep destructive operations behind explicit confirmation or a dedicated hook.
````

- [ ] **Step 4: Commit**

```bash
git add home/profiles/README.md docs/workflows/ai-agent-workflows.md docs/workflows/mcp-curation.md
git commit -m "docs(ai): document agent dev profile"
```

---

### Task 4: Add AI Python Project Template

**Files:**
- Create: `templates/ai-python/flake.nix`
- Create: `templates/ai-python/.envrc`
- Create: `templates/ai-python/.gitignore`
- Create: `templates/ai-python/pyproject.toml`
- Create: `templates/ai-python/justfile`
- Create: `templates/ai-python/evals/cases.jsonl`
- Create: `templates/ai-python/evals/run_eval.py`
- Create: `templates/ai-python/src/ai_app/__init__.py`

- [ ] **Step 1: Create `templates/ai-python/flake.nix`**

```nix
{
  description = "Python AI application environment with uv and evals";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
            python313
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
```

- [ ] **Step 2: Create `templates/ai-python/.envrc`**

```bash
# shellcheck shell=bash
use flake
```

- [ ] **Step 3: Create `templates/ai-python/.gitignore`**

```gitignore
.env
.venv/
__pycache__/
.pytest_cache/
.ruff_cache/
evals/results.jsonl
```

- [ ] **Step 4: Create `templates/ai-python/pyproject.toml`**

```toml
[project]
name = "ai-app"
version = "0.1.0"
description = "Small AI application with reproducible evals"
requires-python = ">=3.13"
dependencies = [
  "openai>=1.0.0",
  "python-dotenv>=1.0.0",
  "rich>=13.0.0",
]

[dependency-groups]
dev = [
  "pytest>=8.0.0",
  "ruff>=0.8.0",
]

[tool.ruff]
line-length = 100
target-version = "py313"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

- [ ] **Step 5: Create `templates/ai-python/justfile`**

```make
setup:
    uv sync

lint:
    uv run ruff check .

format:
    uv run ruff format .

test:
    uv run pytest

eval model="gpt-5-mini":
    uv run python evals/run_eval.py --model {{model}} --cases evals/cases.jsonl --output evals/results.jsonl
```

- [ ] **Step 6: Create `templates/ai-python/evals/cases.jsonl`**

```jsonl
{"id":"summarize-1","input":"Summarize this in one sentence: Nix flakes make development environments reproducible across machines.","must_contain":["reproducible","development"]}
{"id":"classify-1","input":"Classify the sentiment as positive, neutral, or negative: The build passed after the guardrail check.","must_contain":["positive"]}
```

- [ ] **Step 7: Create `templates/ai-python/evals/run_eval.py`**

```python
#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console


def load_cases(path: Path) -> list[dict]:
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def score_case(output: str, must_contain: list[str]) -> bool:
    text = output.lower()
    return all(term.lower() in text for term in must_contain)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="gpt-5-mini")
    parser.add_argument("--cases", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    load_dotenv()
    client = OpenAI()
    console = Console()
    cases = load_cases(args.cases)
    results = []

    for case in cases:
        response = client.responses.create(
            model=args.model,
            input=case["input"],
        )
        output = response.output_text
        passed = score_case(output, case["must_contain"])
        results.append({
            "id": case["id"],
            "passed": passed,
            "output": output,
        })
        console.print(f"{case['id']}: {'PASS' if passed else 'FAIL'}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(json.dumps(row) for row in results) + "\n")

    failures = [row for row in results if not row["passed"]]
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 8: Create `templates/ai-python/src/ai_app/__init__.py`**

```python
"""AI application package."""
```

- [ ] **Step 9: Verify template local files parse**

Run:

```bash
nix flake check --no-build ./templates/ai-python
```

Expected: exits 0.

- [ ] **Step 10: Commit**

```bash
git add templates/ai-python
git commit -m "feat(templates): add AI Python eval project"
```

---

### Task 5: Register The AI Python Template

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add `ai-python` to the `templates` attrset**

Insert this entry beside the existing `python` template:

```nix
          ai-python = {
            path = ./templates/ai-python;
            description = "Python AI app with uv, OpenAI Responses API evals, and direnv";
          };
```

- [ ] **Step 2: Verify template appears in flake metadata**

Run:

```bash
nix flake show --json | jq '.templates."ai-python".description'
```

Expected:

```json
"Python AI app with uv, OpenAI Responses API evals, and direnv"
```

- [ ] **Step 3: Verify all templates**

Run:

```bash
nix flake check --no-build
```

Expected: exits 0 and includes `templates.ai-python`.

- [ ] **Step 4: Commit**

```bash
git add flake.nix
git commit -m "feat(flake): expose AI Python project template"
```

---

### Task 6: Update README Entry Points

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add a short AI workflow section near the development environment documentation**

```markdown
## AI Engineering Workflow

This repo includes an optional Home Manager profile for AI-assisted development:

- `profiles.agentDev.enable = true` installs local agent workflow commands.
- `profiles.agentDev.hermes.enable = true` installs Hermes Agent when available for the host platform.
- `agent-guard` checks agent-generated changes before review.
- `agent-eval-host mbp2` evaluates a Darwin host output without building it.
- `nix flake init -t ~/nix-config#ai-python` creates a Python AI app with uv and evals.
- `docs/workflows/ai-agent-workflows.md` describes the review loop.
- `docs/workflows/mcp-curation.md` describes MCP discovery and safe tool use.
```

- [ ] **Step 2: Verify Markdown-only change is clean**

Run:

```bash
git diff --check README.md docs/workflows home/profiles/README.md
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs(ai): add AI engineering workflow entry points"
```

---

### Task 7: Final Verification

**Files:**
- Read: all changed files from this plan

- [ ] **Step 1: Verify profile-enabled commands appear on `mbp2`**

```bash
nix eval --impure --json --expr 'let flake = builtins.getFlake "git+file:///Users/wm/nix-config"; names = map (pkg: pkg.name or "") flake.darwinConfigurations.mbp2.config.home-manager.users.wm.home.packages; in builtins.filter (name: name == "agent-guard" || name == "agent-eval-host") names'
```

Expected:

```json
["agent-guard","agent-eval-host"]
```

- [ ] **Step 2: Build the `mbp2` Home Manager activation package**

```bash
nix build --no-link --impure --expr 'let flake = builtins.getFlake "git+file:///Users/wm/nix-config"; in flake.darwinConfigurations.mbp2.config.home-manager.users.wm.home.activationPackage'
```

Expected: exits 0.

- [ ] **Step 3: Run guardrails after applying the profile**

After `nixswitch` activates the host configuration, run:

```bash
agent-guard
```

Expected: `agent-guard: ok`, or a deliberate `flake.lock` warning if the lock file is modified. If the only failure is the lock warning, run:

```bash
ALLOW_FLAKE_LOCK=1 agent-guard
```

Expected: `agent-guard: ok`.

- [ ] **Step 4: Run flake check**

```bash
nix flake check --no-build
```

Expected: exits 0.

- [ ] **Step 5: Verify AI template can scaffold**

```bash
repo_root="$PWD"
tmpdir="$(mktemp -d)"
(cd "$tmpdir" && nix flake init -t "$repo_root#ai-python" && nix flake check --no-build)
rm -rf "$tmpdir"
```

Expected: exits 0.

- [ ] **Step 6: Run whitespace check**

```bash
git diff --check
```

Expected: no output.

- [ ] **Step 7: Summarize**

Record in the final response:

```text
Implemented optional profiles.agentDev capability, moved Hermes Agent into that profile, enabled it on mbp2, added ai-python template, MCP workflow docs, and README entry points.
Verified with: profile package eval, mbp2 home activation build, agent-guard after activation, nix flake check --no-build, template scaffold check, git diff --check.
```
