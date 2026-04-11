# Changelog

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
