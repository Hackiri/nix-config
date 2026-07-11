# Nix Fleet Modernization Program Design

**Date:** 2026-07-11
**Audience:** Personal multi-host fleet
**Primary platforms:** Apple Silicon macOS, NixOS desktop, and NixOS server
**Legacy platform:** Intel macOS on a frozen compatibility branch
**Delivery model:** Five independently planned and validated phases

## Purpose

Modernize the complete configuration without turning it into a generic public
framework. Preserve intentional tools, preferences, keybindings, and workflows,
while replacing obsolete workarounds, destructive activation behavior, hidden
side effects, and weak validation.

The current repository has a strong modular foundation, but the audit found a
broken Intel evaluation, an untested NixOS claim, overlapping package ownership,
destructive Homebrew and application activation, global Git hook interference,
mutable editor setup, shell initialization hazards, stale tests, and CI that
evaluates checks without consistently executing them.

## Approved Decisions

- Maintain Intel macOS beyond upstream support on a dedicated `legacy-intel`
  branch rather than carrying old and current module APIs together on `main`.
- Promote NixOS to first-class support with desktop and server roles.
- Optimize for this personal fleet, not for a reusable public framework.
- Use balanced package ownership: daily development tools remain global on
  developer workstations; heavyweight or specialized stacks move to named
  capabilities or development shells.
- Treat Homebrew as a safe declarative inventory. Normal switches detect drift
  but do not upgrade, uninstall, or zap software implicitly.
- Apply modern-safe behavior changes: preserve intentional UX, but remove or
  replace unsafe defaults, obsolete compatibility shims, implicit file creation,
  and destructive activation.
- Keep system and Home Manager state versions host-local and stable. Input
  updates do not justify state-version changes.
- Preserve the existing uncommitted `hosts/mbp2/home.nix` SOPS import throughout
  the work; it is user-owned and is not part of the modernization commits unless
  the user later requests that explicitly.

## Program Boundaries

The work is too large for one implementation plan. It is divided into five
subprojects, each with its own specification, implementation plan, verification,
and review checkpoint. The decisions in this document are global constraints for
all five subprojects and will not be reopened unless implementation evidence
reveals a contradiction.

The first implementation cycle covers only Phase 1. Later phases begin after the
previous phase leaves its target branch green and buildable.

## Branch and Platform Architecture

### `legacy-intel`

`legacy-intel` preserves the `mbp` host and the last complete stack that can
evaluate and build `x86_64-darwin`.

The baseline will be created from the latest committed configuration, followed by
an Intel compatibility repair. Stable Nixpkgs 26.05 already provides the same
Neovim and Neovide versions currently imported from unstable, so the baseline
will use the stable package set instead of the incompatible Nixpkgs 26.11 input.

The branch policy is:

- Freeze Nixpkgs, nix-darwin, Home Manager, and related module inputs at verified
  26.05-compatible revisions.
- Disable scheduled broad input updates.
- Accept only targeted compatibility, security, and application-source repairs.
- Validate the `mbp` system derivation and repository checks before every change.
- Tag the initial verified baseline for recovery.
- Keep publication of the local branch to the remote as a separate, explicit
  external action.

Homebrew tap revisions may receive targeted updates when an upstream application
source stops working, but such updates do not move the frozen Nix module stack.

### `main`

`main` becomes the current-platform branch:

- Apple Silicon Darwin remains represented by `mbp2`.
- The Intel `mbp` host and global `x86_64-darwin` compatibility constraints move
  to `legacy-intel`.
- Current stable Nixpkgs, nix-darwin, and Home Manager may advance together.
- NixOS desktop and server roles are continuously evaluated.
- Project templates consume the same role modules as real configurations.

## Role Composition

Host discovery remains metadata-driven, but host composition becomes explicit and
role-oriented.

### System bases

- Shared base: device facts, common user plumbing, fonts, and Nix integration.
- Darwin base: neutral macOS system integration without workstation application
  policy.
- NixOS base: neutral boot-independent operating-system defaults without
  automatically enabling OpenSSH, Podman, a desktop, or an agent service.

### System roles

- Darwin workstation: macOS defaults, firewall, power, Homebrew, and application
  integration.
- NixOS desktop: graphical session, display manager, audio, printing, and
  desktop-specific packages.
- NixOS server: headless defaults, server security posture, and remote-management
  foundations.

OpenSSH, Podman, Hermes, Redis, Kubernetes, SOPS, and similar workloads remain
explicit capabilities. A role may recommend a capability, but the neutral base
does not silently enable it.

### Home Manager roles

- Foundation: shell essentials and cross-platform user defaults.
- Developer: daily build, Git, Nix, Python/uv, formatter, and database-client
  tools. Other language toolchains remain project-shell or explicit host
  concerns.
- Graphical workstation: editors, terminals, graphical utilities, and desktop
  integrations.

The current complete program registry becomes a workstation concern. A headless
server does not receive Emacs, Neovim GUI tooling, Kitty, AeroSpace configuration,
or workstation daemons unless its host explicitly imports them.

Host files import roles directly instead of selecting a large matrix of Boolean
feature flags. Host-specific state versions remain in the host configuration.

## NixOS First-Class Support

Two hardware-independent fixtures exercise the actual NixOS roles:

- Desktop fixture: evaluates the shared base, NixOS base, desktop role, and its
  Home Manager composition.
- Server fixture: evaluates the shared base, NixOS base, server role, and a
  minimal headless Home Manager composition.

Fixtures contain no private hardware identifiers or secret dependencies. The
desktop and server templates import the same production role modules, so fixture,
template, and future host behavior cannot drift independently.

## Package and Input Ownership

### Ownership rules

- Foundation owns generic command-line utilities.
- Developer owns general development tools used across domains.
- Workstation owns interactive editor, terminal, and desktop tooling.
- Capabilities own only their domain-specific packages and behavior.
- Development shells own heavyweight, specialized, or project-scoped stacks.

The same derivation must not be intentionally added by multiple roles or
capabilities. In particular, Kubernetes and agent capabilities will stop adding
baseline utilities such as `jq`, `wget`, `fzf`, `ripgrep`, `uv`, Alejandra,
Deadnix, and Statix.

### Balanced workstation inventory

Developer workstations retain core build tools, Git tooling, Nix tooling,
Python/uv, common formatters, and daily database clients.

The normal Kubernetes capability retains daily administration tools including
`kubectl`, Helm, k9s, context management, and manifest validation. Heavyweight
cloud, IaC, GitOps, service-mesh, security-scanning, and distribution stacks move
to named shells such as `cloud`, `iac`, and `kubernetes-ops`.

### Inputs and overlays

- Remove the root unstable input when no enabled package requires it.
- Use stable Neovim and Neovide on `main`; their audited stable versions match the
  current unstable selections.
- Replace automatic overlay discovery with an explicit ordered overlay list.
- Install Hermes from its input package directly instead of extending every
  package set to expose it globally.
- Retain the Emacs overlay explicitly for its package recipes while continuing to
  use stable Emacs 30 on `main`; stop naming the stable configured binary as if it
  were an Emacs Git snapshot.
- Restrict unfree evaluation initially to `omnictl`; additions require an explicit
  reviewed whitelist change.
- Retain and document the `hackiri/nix-homebrew` fork because it supplies the
  declarative Homebrew trust support used by this configuration. Moving back to
  upstream is a later change only after upstream reaches functional parity.

## Application and Homebrew Ownership

Homebrew owns third-party GUI applications and macOS-specific software that are
not supplied by Nix, under the configured user application directory. Nix owns
GUI programs selected from Nixpkgs. Every configured Homebrew application,
including AeroSpace and JankyBorders when their repository configuration is
enabled, must appear in the declarative inventory.

Normal activation uses:

- Drift detection with `homebrew.onActivation.cleanup = "check"`.
- No implicit metadata update.
- No implicit package or cask upgrade.
- No automatic uninstall or `zap`.

Explicit maintenance commands provide reviewable upgrade and prune workflows.
Destructive pruning requires a dedicated command and is never part of an ordinary
system switch. `nix-homebrew.autoMigrate` is disabled after the existing
installation has been confirmed migrated.

Nix-installed GUI applications use nix-darwin's current rsync-based application
reconciliation under `/Applications/Nix Apps`. The custom `mkForce` activation
that deletes that directory and replaces applications with aliases is removed.

Gatekeeper remains enabled. Phase 3 removes the LibreWolf post-install quarantine
bypass. Any future exception requires a separate reviewed change with a
reproducible failure and a narrowly scoped rationale.

## Secrets and Git Identity

The SOPS capability becomes a generic mechanism:

- Git name, email, and signing key are rendered into a protected Git include file
  with `sops.templates`.
- Home Manager includes that generated file from the global Git configuration.
- SOPS no longer installs global checkout/merge hooks or owns
  `core.hooksPath`.
- Repository-local hooks and pre-commit tooling work normally.
- Host-specific SSH configuration secrets live in their host modules.
- System SOPS modules are imported only by roles or hosts that use system-level
  secrets; Home Manager-only hosts do not receive unused system modules.
- The existing key permissions remain restrictive.

Recovery-recipient creation, offline storage, rotation, and re-encryption are
documented. No private recovery material is generated or committed by this work.

## Runtime and Activation Behavior

### macOS activation

- Remove the root-owned screenshot-directory `chown`; create user directories
  through Home Manager or a safe user-context mechanism.
- Remove unconditional mutable disabling of the built-in Apache service.
- Prefer typed nix-darwin defaults for Activity Monitor, screen locking, and
  other supported preferences.
- Remove ineffective MDM-style preference claims; document FileVault bootstrap
  and verify its status separately from preference files.
- Keep firewall, stealth mode, Gatekeeper, immediate locking, automatic system
  updates, and Touch ID sudo.
- Move static DNS out of the shared Darwin role. No `main` host opts in initially;
  a host may later declare explicit DNS servers when that behavior is intentional.

### Shell behavior

Existing aliases, keybindings, tmux layouts, and interactive workflows remain
unless they depend on a removed unsafe behavior.

- Do not globally force `TERM`; terminals and tmux own their negotiated values.
- Set `LANG` without globally forcing `LC_ALL`.
- Run one Home Manager-managed Zsh completion initialization.
- Keep the existing macOS `/bin/zsh` login shell and remove the ineffective Nix
  login-shell assignment.
- Remove legacy per-user `nix.sh` sourcing under Determinate Nix.
- Remove implicit direnv evaluation from noninteractive shells.
- Replace the directory-change hook that writes, hides, and authorizes project
  files with an explicit project bootstrap command.
- Use current Home Manager modules for zoxide, fzf, and other supported programs.
- Remove `reattach-to-user-namespace` after a macOS 26 tmux clipboard smoke test
  passes without it. A failed smoke test retains the package and records the exact
  failing operation as a temporary compatibility exception.

### Editors and scripts

Doom Emacs source is pinned. Its immutable source and mutable data/cache are
separated, and synchronization becomes an explicit `doom-sync` command rather
than a network operation during every Home Manager activation.

Large embedded shell utilities are split into focused files and packaged with
`writeShellApplication`, explicit runtime inputs, and ShellCheck validation.
Modules retain declarative program settings and package wiring rather than
containing hundreds of lines of unrelated shell behavior.

### Services

Redis, Podman, Hermes, Emacs daemon mode, and similar long-running processes are
enabled only by explicit workstation or server composition. Runtime directories
are created without following user-controlled symlinks from privileged code.

## Validation and Failure Handling

### Canonical command

`just check` becomes the authoritative local and CI entry point. It runs:

- The locked treefmt/git-hooks check for Nix, Lua, shell, and documentation.
- Alejandra, Deadnix, and Statix through the locked package set.
- Semantic configuration assertions.
- Every declared Darwin host evaluation on its branch.
- NixOS desktop and server fixture evaluations on `main`.
- Focused tests for packaged shell applications.

CI uses the same entry point. It builds native checks rather than only evaluating
them with `--no-build`, and it does not fetch mutable registry tools through
`nixpkgs#...`.

### Semantic tests

Brittle total package counts and exact import-topology grep tests are removed.
Their replacements assert behavior:

- Required roles and hosts evaluate.
- Invalid role/platform combinations fail with clear messages.
- Platform-specific packages do not enter the wrong platform closure.
- Capabilities add their documented packages and services.
- Generic package ownership is not duplicated across enabled components.
- Fixtures never depend on private secrets or machine-specific hardware data.

### Update automation

Dependency updates validate before an update pull request is created. The update
documentation uses current Nix commands. Repository checks must be required by
the hosting platform before merging; changing remote branch-protection settings
is outside this local implementation unless separately authorized.

The tracked machine-specific `.pre-commit-config.yaml` store symlink is removed
from Git. Generated pre-commit configuration remains untracked and symlink
creation correctly handles dangling links. The broad `docs/*` ignore rule is
narrowed so maintained design and workflow documentation is visible.

### Error policy

- Assertions reject invalid metadata and role combinations during evaluation.
- Activation checks run before mutation.
- Destructive actions require explicit maintenance commands.
- Expected optional absence yields an actionable warning.
- A host that declares SOPS fails clearly when its key material is unavailable;
  fixtures and hosts that do not declare SOPS remain independent.
- Broad `|| true` handling is removed from required behavior and retained only
  where failure is explicitly non-fatal and documented.

## Delivery Phases

### Phase 1: Intel preservation and foundation correctness

- Establish and validate the `legacy-intel` baseline.
- Remove incompatible/unnecessary unstable package selection.
- Repair `main` evaluation.
- Introduce the canonical validation command.
- Execute locked checks in CI and update automation.
- Replace stale structural tests with the first semantic checks.
- Remove the tracked dangling pre-commit symlink and repair generation logic.

Phase 1 is the scope of the first implementation plan.

### Phase 2: Role architecture and NixOS fixtures

- Separate neutral bases from Darwin workstation, NixOS desktop, and NixOS
  server policy.
- Introduce explicit Home Manager roles.
- Add NixOS desktop and server fixtures.
- Align templates with production roles.

### Phase 3: Package, application, Homebrew, and secret ownership

- Deduplicate packages and create balanced development shells.
- Make Homebrew drift checking safe and maintenance explicit.
- Restore nix-darwin application management.
- Replace SOPS Git hooks with a generated include.
- Move host-specific secrets back to hosts.

### Phase 4: Runtime, shell, editor, and service modernization

- Remove obsolete shell and activation behavior.
- Package substantial shell utilities with declared dependencies and tests.
- Pin Doom and make synchronization explicit.
- Make long-running services role/capability owned.
- Migrate supported raw preferences to typed options.

### Phase 5: Documentation, templates, and final audit

- Update the README, profile map, program documentation, and maintenance guides.
- Verify templates from clean instantiations.
- Re-run the full security, architecture, package, and validation audit.
- Compare package lists and closure sizes against the recorded baseline.
- Record intentional remaining exceptions and their owners.

## Verification Checkpoints

Every phase must satisfy its branch-specific `just check` before completion.
Repository builds are automated. Actual `darwin-rebuild switch` and NixOS
activation remain user-controlled checkpoints.

Phase-specific changes are committed separately so a regression can be reverted
without undoing unrelated modernization work.

## Success Criteria

- `legacy-intel` evaluates and builds `mbp` with a frozen compatible stack.
- `main` evaluates and builds `mbp2` without the current Intel/unstable failure.
- NixOS desktop and server roles evaluate continuously from real shared modules.
- CI executes locked checks and catches input regressions before merge.
- Package and service ownership is explicit and non-duplicative.
- The Apple Silicon workstation closure is measurably smaller while preserving
  the approved daily toolset.
- Ordinary activation performs no hidden network clone, package upgrade,
  application deletion, Homebrew zap, or global Git hook takeover.
- Shell startup does not override terminal capabilities or mutate projects.
- Secrets remain encrypted at rest and no private recovery material enters Git.
- Documentation describes actual commands, ownership, roles, and maintenance.

## Non-Goals

- Supporting Intel macOS indefinitely with current upstream packages.
- Turning this repository into a general-purpose public Nix framework.
- Automatically changing system state versions.
- Automatically activating rebuilt operating-system configurations.
- Managing FileVault escrow or MDM policy from plain Nix preferences.
- Generating or storing private SOPS recovery keys.
- Changing remote repository settings or publishing branches without separate
  authorization.
