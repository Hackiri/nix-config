# Task 3 Report: Convert Templates And Scaffold Docs

## What I implemented
- Updated `templates/nixos-desktop/home.nix` to import `../../home/programs`, bind `programRegistry`, and append `programRegistry.suites.workstation.nixos` to `imports`.
- Updated `templates/host/home.nix` to demonstrate the registry pattern with `programRegistry = import ../../home/programs;` and commented examples for both `darwin` and `nixos` suites.
- Updated `templates/host/README.md` to explain that program modules are selected through `home/programs/default.nix` and to show the registry-based host template example, while keeping the existing scaffold instructions intact.
- Extended `tests/program-imports.sh` with `check_nixos_template_imports()` and added the NixOS desktop template check before the success print.

## TDD evidence

### RED
Command:
```bash
bash -x tests/program-imports.sh
```
Output:
```text
+ set -euo pipefail
++ git rev-parse --show-toplevel
+ cd /Users/wm/nix-config/.worktrees/program-import-tree
++ nix eval --impure --expr 'let r = import ./home/programs; in builtins.length r.suites.workstation.darwin'
+ registry_darwin_count=18
++ nix eval --impure --expr 'let r = import ./home/programs; in builtins.length r.suites.workstation.nixos'
+ registry_nixos_count=17
+ '[' 18 = 18 ']'
+ '[' 17 = 17 ']'
+ git grep -nE '(\.\./)+programs' -- ':(glob)home/profiles/**/*.nix'
+ check_darwin_host_imports hosts/mbp/home.nix
+ check_darwin_host_imports hosts/mbp2/home.nix
+ check_nixos_template_imports templates/nixos-desktop/home.nix
+ check_import templates/nixos-desktop/home.nix 'programRegistry = import ../../home/programs;'
+ git grep -q 'programRegistry = import ../../home/programs;' -- templates/nixos-desktop/home.nix
 fail 'templates/nixos-desktop/home.nix does not import programRegistry = import ../../home/programs;'
 printf 'program-imports: %s\n' 'templates/nixos-desktop/home.nix does not import programRegistry = import ../../home/programs;'
 exit 1
 program-imports: templates/nixos-desktop/home.nix does not import programRegistry = import ../../home/programs;
 error: recipe `program-imports` failed on line 20 with exit code 1
 ```
Result: failed as expected before the template update.

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
Result: passed after the template and docs updates.

## Exact tests and results
- `bash -x tests/program-imports.sh` -> exit 1 on the expected missing NixOS template import
- `just program-imports` -> exit 0

## Files changed
- `tests/program-imports.sh`
- `templates/nixos-desktop/home.nix`
- `templates/host/home.nix`
- `templates/host/README.md`

## Self-review findings
- The NixOS desktop template now follows the same registry pattern as the Darwin host templates.
- The generic host scaffold now shows both `programRegistry.suites.workstation.darwin` and `programRegistry.suites.workstation.nixos`.
- The README kept its existing usage guidance and only gained the registry-pattern explanation.
- The import test now covers the NixOS desktop template without reintroducing granular `home/programs` imports.

## Concerns
- None.
