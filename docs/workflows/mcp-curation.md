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
