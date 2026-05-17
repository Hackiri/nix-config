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
