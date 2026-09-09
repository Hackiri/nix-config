# Changelog

## 2026-09-07

### Packages

- **feat(kubernetes):** Add the HashiCorp Vault CLI to the Kubernetes security tool set, gated on `allowUnfree` (`7988b9a`)

## 2026-09-05

### Emacs

- **fix(emacs):** Fetch Doom's `sources/doom+` submodule so every module referenced by `doom.d/init.el` exists in the pinned checkout (`618a5bd`, `01216c9`)
  - Switched the Doom source pin to `fetchFromGitHub` with `fetchSubmodules = true`
  - Dropped package recipes that no longer resolve
  - Fixed the launchd environment so the Emacs agent inherits `DOOMDIR` and `DOOMLOCALDIR`
  - Restored an automatic `doom sync` after activation

### Secrets

- **refactor(sops):** Move per-host secret declarations into `hosts/<host>/sops.nix` and leave the shared machinery in `home/profiles/capabilities/sops.nix` (`adcb742`)

## 2026-09-04

### Flake & Hosts

- **refactor(home-manager):** Update the Home Manager host definitions and the flake wiring around them (`a020b9f`, `2f2af1b`)
- **feat(ci):** Harden the configuration and the GitHub Actions workflows, and refresh the validation workflow set (`cae8f3d`, `f79a9a8`)

## 2026-09-02

### Development Shells

- **feat(python):** Add `python-dotenv` to the Python development shell (`f2a9284`)

## 2026-08-20

### Overlays

- **chore(overlays):** Drop the obsolete overlays and use `pkgs.emacs` directly (`4785eca`)

## 2026-08-19

### Agent Tooling

- **feat(agent-dev):** Make the agent capability provider-neutral (`2373e31`)
- **refactor:** Drop the Hermes Agent integration (`06bf6c9`)

### Packages & Linting

- **chore(packages):** Drop `statix` and `clamav` from the shared bundles (`fbe7036`)
- **fix(overlays):** Pin `statix` to the last tagged release, then fix the findings it reported (`1d1b496`, `195232e`)
- **fix(emacs):** Pin the Emacs Python tooling to `python314Packages` (`c2d69cf`)
- **chore(devshell):** Add `pyyaml` to the Python shell (`1ebd8aa`)
- **chore(homebrew):** Install `kdash` through Homebrew after its removal from nixpkgs (`af9dbc5`)

## 2026-07-25

### Neovim

- **refactor(neovim):** Adopt the Neovim 0.12 APIs (`89ce1f3`)
- **fix(neovim):** Harden the lazy.nvim bootstrap (`5dfb88f`)
- **chore(neovim):** Remove the unused init entrypoint (`f23b200`)

## 2026-07-11

### Platform Split

- **refactor:** Move the Intel Darwin configuration to the `legacy-intel` branch and document the current and legacy platform lines (`eff22c8`, `eebdbb0`)
- **fix:** Keep the Darwin editors on stable nixpkgs (`56b6594`)
- **fix:** Provide `xcodebuild` to Bitwarden on Darwin (`7eb18d9`)

### CI & Validation

- **ci:** Execute the canonical locked checks and preserve the lock during workflow checks (`49089c8`, `79f2013`)
- **test:** Replace the import guards with semantic checks (`d3ac190`)
- **fix:** Reconcile the generated pre-commit config safely (`ec46ab9`)

## 2026-07-04

### Homebrew & Packages

- **chore:** Move the Darwin CLI tools to Nix (`10264e7`)
- **chore:** Switch to the `nix-homebrew` fork (`00ff62e`)
- **fix:** Update the Darwin Homebrew trust configuration and add the LibreWolf quarantine post-install step (`4382bb9`, `924cb80`)
- **fix:** Configure the Yazi realpath resolver (`55ddd21`)

## 2026-06-28

### Toolchain

- **chore:** Move the Python tooling from `python313` to `python314` (`c1e8897`, `2983f1f`)
- **fix:** Disable the redundant Darwin Home Manager font sync (`99b2659`)

## 2026-06-19

### Program Import Registry

- **refactor:** Add the program import registry and select package bundles through imports (`978332e`, `d83521b`)
- **refactor:** Make the home capabilities import-only and select the Darwin program suite from the hosts (`427c6b6`, `13cdeea`)
- **docs:** Clarify profile and program ownership and teach the host templates about program suites (`fdf9b9b`, `3695162`, `7d571d3`)

### Homebrew

- **chore:** Manage Homebrew declaratively, preserve manual installs, and allow manual brew updates (`05d1e7a`, `c0c0663`, `fca7afb`)
- **feat:** Add the k9s watch-list workaround (`5477b3b`)

## 2026-06-06

### Packages

- **refactor(darwin):** Migrate the Homebrew CLI packages to Nix (`fbe5393`)
- **fix(homebrew):** Avoid cask fetch failures during activation and make Homebrew updates manual (`5ffc35d`, `d3f9efd`)

## 2026-05-30

### Nix Release

- **chore:** Move the configuration to the 26.05 release channels (`ce61b27`)

## 2026-05-17

### Agent Development

- **feat(home):** Add the optional agent development profile, then the `agent-dev` and `redis` capabilities (`cab4533`, `0aa1f60`)
- **refactor(agent-dev):** Auto-discover the Darwin hosts for `agent-guard` (`c384ebe`, `ae8c4b3`)
- **feat(templates):** Add the AI Python evaluation project and expose it as a flake template (`729b9a5`, `a0601dd`)
- **docs(ai):** Document the agent development profile and the AI engineering workflow entry points (`3a1aab1`, `6e85079`)

### Tmux

- **feat(tmux):** Add the layout picker script and bind it to `Prefix+L` (`86a39a6`, `531db34`, `08fd100`)

## 2026-05-05

### Neovim & Terminals

- **feat(nvim):** Add the clipboard and formatting helpers and expand the Rust snippets (`6f1950b`, `d6ab22a`)
- **perf(neovim):** Lazy-load the LuaSnip snippets (`3da70ae`)
- **feat(terminals):** Add the tmux and sesh workflow helpers (`367cafc`)

## 2026-04-30

### CI

- **ci:** Update the GitHub Actions to Node.js 24 and add the OIDC permissions described in the Determinate documentation (`d82c558`, `4385d1e`)

## 2026-04-25

### Unified Workflows

- **feat:** Adopt `treefmt` and `just` for unified formatting and validation workflows (`1a61e50`)
- **fix:** Point the pre-commit treefmt hook at the Nix-built wrapper and make the pre-commit shell hook safe (`7282253`, `dbceb70`)
- **refactor:** Tighten the Darwin modules and de-duplicate the sops hooks (`4e15c6e`)

## 2026-04-24

### Homebrew

- **fix(homebrew):** Align `brew-src` with the pinned taps and add the krunkit formula on Apple Silicon only (`3f0b9d5`, `7a64191`)

## 2026-04-23

### Home Profiles & Packages

- **refactor(home):** Reorganize Home Manager profiles and package bundles into clearer taxonomy (`b1ad2d0`)
  - `home/profiles/base/` → `home/profiles/layers/`
  - `home/profiles/features/` → `home/profiles/capabilities/`
  - `home/profiles/platform/` → `home/profiles/platforms/`
  - `home/packages/` split into `core/`, `development/`, and `platform/`
  - Moved Kubernetes `k9s` assets alongside the Kubernetes capability module
  - Updated hosts, templates, and profile docs to use the new paths

### Pre-commit & Dev Shell

- **refactor(devshell):** Make pre-commit tooling coexist with custom `core.hooksPath` (`b1ad2d0`)
  - Default `nix develop` shell now provides pre-commit tooling without forcing hook installation
  - Added explicit `install-pre-commit-hook` workflow for repo-local hook installation
  - Added `pcinstall` alias and updated README troubleshooting/docs

### Darwin & Builders

- **refactor(darwin):** Simplify Darwin PATH handling and reduce duplication (`bb6a603`)
  - Removed redundant `home.sessionPath` additions for `/run/current-system/sw/bin` and `$HOME/.nix-profile/bin`
  - Removed duplicate Homebrew `coreutils` since it is already provided system-wide

- **refactor(builders):** Tighten builder plumbing and host discovery (`bb6a603`)
  - Extracted pre-commit hook installer to `lib/install-pre-commit-hook.nix`
  - Made `allowDeprecatedx86_64Darwin` conditional on Intel Darwin only
  - Replaced silent `tryEval` host discovery behavior with explicit metadata validation

### Programs & Host Modules

- **refactor(home-programs):** Update Home Manager program modules and related host config (`fa8880d`)
  - Refreshed shell, editor, terminal, utility, and host/module configuration files
  - Applied formatter/linter-driven normalization across touched modules

## 2026-04-22

### Host Discovery & Templates

- **refactor(hosts):** Harden auto-discovery to ignore incomplete host directories (`d55bf40`)
  - `lib/builders.nix` now only discovers hosts when `meta.nix`, `configuration.nix`, and `home.nix` all exist and `meta.nix` evaluates cleanly
  - Updated `README.md` to document the host discovery rule and staging workflow

- **refactor(templates):** Replace tracked `hosts/desktop` with `templates/nixos-desktop` scaffold (`8b511c7`)
  - Moved the old desktop host into a reusable NixOS desktop template
  - Added template README and Home Manager entrypoint
  - Updated host/template docs and related references in `PROFILE_MAP.md`, `flake.nix`, and setup guidance

## 2026-04-02

### Flake Modularization

- **refactor(flake):** Extract overlays, builders, and pre-commit config from `flake.nix` into dedicated files (`82569e3`)
  - `lib/builders.nix` — mkHomeManagerConfig, mkDarwin, mkNixOS
  - `lib/pre-commit.nix` — git-hooks configuration
  - `overlays/neovim.nix` — neovim-unstable overlay
  - `overlays/*.nix` — accept `{ inputs }` for input-dependent overlays
  - `flake.nix` outputs section reduced from ~165 to ~75 lines

### Theme & UI

- **feat:** Add Eldritch color palette to Starship prompt (`4e12bcf`)
- **feat:** Enable JankyBorders with Eldritch green focus border for AeroSpace (`4e12bcf`)
- **feat:** Add `jankyborders` package to darwin-pkgs (`4e12bcf`)
- **feat:** Adjust AeroSpace gaps (inner 15, outer 12) (`4e12bcf`)

### Neovim 0.12 Migration

- **feat(neovim):** Enable codelens and DiffTool improvements (`3f14f9e`)
- **feat(neovim):** Add keymap for built-in `:Undotree` (`5e4f826`)
- **fix(neovim):** Undotree requires `packadd` in 0.12 (`f4c79fd`)
- **refactor(neovim):** Remove treesitter compat shim for 0.12 (`97f9185`)
- **refactor(neovim):** Use native `vim.treesitter` APIs in folding.lua (`4dcf347`)
- **refactor(neovim):** Remove redundant `pcall` around `get_parser` (`dafbb82`)
- **docs(neovim):** Update LSP config comment for 0.12 defaults (`d9e1073`)
- **feat:** Update neovim comment for nixpkgs-unstable overlay (`4e12bcf`)

### Shell & Terminal

- **feat:** Add verbose zsh completions and fzf-tab show-group (`4e12bcf`)
- **feat:** Change tmux rename-session binding to `prefix+R` (`4e12bcf`)

### Sesh / Tmux Session Management

- **feat:** Add sesh session manager module (`a1eda30`)
- **refactor:** Update tmux keybindings for sesh integration (`a8e8fca`)
- **refactor:** Remove custom session scripts replaced by sesh (`f7960af`)
- **refactor:** Migrate fzf to declarative home-manager module (`198c331`)

### System & Packages

- **feat:** Add mkalias activation script and power management (`dc2d56d`)
- **refactor:** Encapsulate nix-homebrew config in homebrew module (`e54d919`)
- **refactor:** Split `preferences.nix` into `defaults/` sub-modules (`1e26ea3`)
- **feat:** Remove tmuxinator, webp, wordnet from packages/brews (`4e12bcf`)
- **feat:** Update all flake inputs, add nixpkgs-unstable (`4e12bcf`)

### Fixes

- **fix:** Address code review issues in activation.nix (`d8b653c`)
- **fix:** Disable avante when copilot is not authenticated (`3a3f1e1`)

### Docs

- **docs:** Update PROFILE_MAP.md — neofetch to fastfetch, add ghostty (`4e12bcf`)
