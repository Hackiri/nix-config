# Task 1 Report: Program Registry And Import Test

## Implemented

- Added `home/programs/default.nix` as a static registry that exports:
  - `programRegistry.suites.workstation.darwin :: list path`
  - `programRegistry.suites.workstation.nixos :: list path`
- Added `tests/program-imports.sh` to verify:
  - registry counts are `18` for Darwin and `17` for NixOS
  - `home/profiles` no longer imports program modules via relative `../programs` paths
  - `home/programs` no longer depends on `profiles.development` gates
- Added `just program-imports` to `justfile`
- Injected `programRegistry` through the Home Manager / system builder arguments in `lib/builders.nix`
- Rewired `home/profiles/layers/*` and `home/profiles/platforms/darwin.nix` to consume the registry instead of direct program imports
- Renamed program-module gating references from `profiles.development` to `profiles.workspace` and added an alias module so existing host-level settings continue to work

## Tests And Results

- `just program-imports`
  - First run: failed as expected because `tests/program-imports.sh` did not exist yet
  - Final run: passed and printed `program-imports: ok`
- `git diff --check`
  - Passed with no output

## TDD Evidence

### RED

Command:

```bash
just program-imports
```

Output:

```text
bash tests/program-imports.sh
bash: tests/program-imports.sh: No such file or directory
error: recipe `program-imports` failed on line 20 with exit code 127
```

### GREEN

Command:

```bash
just program-imports
```

Output:

```text
bash tests/program-imports.sh
program-imports: ok
```

## Files Changed

- `home/programs/default.nix`
- `tests/program-imports.sh`
- `justfile`
- `lib/builders.nix`
- `home/profiles/layers/foundation.nix`
- `home/profiles/layers/development.nix`
- `home/profiles/platforms/darwin.nix`
- `home/profiles/README.md`
- `home/programs/development/direnv/default.nix`
- `home/programs/development/git/default.nix`
- `home/programs/editors/emacs/default.nix`
- `home/programs/editors/neovide/default.nix`
- `home/programs/editors/neovim/default.nix`
- `home/programs/shells/bash/default.nix`
- `home/programs/shells/starship/default.nix`
- `home/programs/shells/zsh/aliases.nix`
- `home/programs/shells/zsh/completion.nix`
- `home/programs/shells/zsh/default.nix`
- `home/programs/shells/zsh/direnv-hook.nix`
- `home/programs/shells/zsh/fzf-cilium.nix`
- `home/programs/shells/zsh/fzf-claude.nix`
- `home/programs/shells/zsh/fzf-git.nix`
- `home/programs/shells/zsh/fzf-kubectl.nix`
- `home/programs/shells/zsh/fzf.nix`
- `home/programs/shells/zsh/keybindings.nix`
- `home/programs/shells/zsh/options.nix`
- `home/programs/terminals/alacritty/default.nix`
- `home/programs/terminals/ghostty/default.nix`
- `home/programs/terminals/kitty/default.nix`
- `home/programs/terminals/sesh/default.nix`
- `home/programs/terminals/tmux/default.nix`
- `home/programs/terminals/wezterm/default.nix`
- `home/programs/utilities/claude/default.nix`
- `home/programs/utilities/yazi/default.nix`

## Self-Review Findings

- The registry exports the expected workstation suite counts: Darwin `18`, NixOS `17`
- `home/profiles` no longer contains direct relative imports into `home/programs`
- `home/programs` no longer contains `profiles.development` references
- `git diff --check` is clean

## Concerns

- `tests/program-imports.sh` uses `nix eval --impure` because pure evaluation rejects the relative `./home/programs` import in this environment
- `profiles.workspace` is a compatibility alias for `profiles.development`; it preserves existing host settings while moving program-module checks off the old path

## Commit

- `978332e refactor: add program import registry`
