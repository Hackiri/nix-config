# Bitwarden Darwin xcodebuild Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Repair the locked Darwin bitwarden-cli build by declaring the full xcodebuild tool, then advance both Phase 1 branches through the reviewed shared correction.

**Architecture:** Add one auto-discovered overlay that extends only Darwin bitwarden-cli derivations with the missing native build input. Verify both declared Darwin package outputs and the canonical repository gate, then update the shared-tip marker and fast-forward the existing legacy worktree without disturbing its staged policy change.

**Tech Stack:** Nix 2.34 flakes, Nixpkgs 26.05, Nix overlays, buildNpmPackage, xcbuild, Bash, Git worktrees.

## Global Constraints

- Use the locked Nixpkgs revision and bitwarden-cli version 2026.4.2; do not update flake.lock or any input.
- Preserve the existing Bitwarden source, npm dependency hash, runtime package interface, and host package composition.
- Add full xcodebuild only to Darwin native build inputs; Linux derivations must remain unchanged.
- Do not modify overlays/default.nix; use its existing auto-discovery interface.
- just check remains the authoritative local validation gate.
- Preserve the user-owned source-worktree hosts/mbp2/home.nix patch with SHA-256 9cde3794bde391a3e48aaaf0a98dc7477f1ef78326c89dfd030556f7932796a0; never stash, revert, stage, or commit it.
- Preserve the two staged Task 5 legacy paths byte-for-byte while advancing legacy-intel.
- Do not activate a configuration, push a ref, create the legacy baseline tag, or change GitHub settings during this correction.
- Use path-specific staging only.

---

### Task 1: Add and Verify the Shared Darwin Bitwarden Overlay

**Files:**

- Create: overlays/bitwarden-cli.nix

**Interfaces:**

- Consumes: overlays/default.nix auto-discovery contract and locked prev.bitwarden-cli/prev.xcodebuild derivations.
- Produces: the same bitwarden-cli package interface, with full xcodebuild appended to nativeBuildInputs only on Darwin.

- [ ] **Step 1: Reproduce the locked Intel package failure**

Run from /Users/wm/nix-config/.worktrees/nix-fleet-phase-1 before creating the overlay:

    nix build --no-link --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.bitwarden-cli

Expected: FAIL in msgpackr-extract@3.0.3 because node-gyp raises FileNotFoundError: xcodebuild. Record the failed derivation and decisive log.

- [ ] **Step 2: Add the minimal platform-conditional overlay**

Create overlays/bitwarden-cli.nix:

    # Nixpkgs 26.05 gives Bitwarden only xcbuild's xcrun output, while node-gyp
    # invokes xcodebuild directly when rebuilding native npm dependencies.
    _: _final: prev: {
      bitwarden-cli = prev.bitwarden-cli.overrideAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
            prev.xcodebuild
          ];
      });
    }

Do not edit overlays/default.nix.

- [ ] **Step 3: Stage the overlay so Git-backed flake evaluation sees it**

Run:

    git add overlays/bitwarden-cli.nix
    test "$(git diff --cached --name-only)" = "overlays/bitwarden-cli.nix"

Expected: exactly the new overlay is staged.

- [ ] **Step 4: Assert the native input on both Darwin configurations**

Run:

    mbp_drv="$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.bitwarden-cli.drvPath)"
    mbp_xcodebuild="$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.xcodebuild.outPath)"
    nix derivation show "$mbp_drv" \
      | jq -e --arg path "$mbp_xcodebuild" '
          .derivations
          | to_entries[0].value.env.nativeBuildInputs
          | split(" ")
          | index($path) != null
        '

    mbp2_drv="$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp2.pkgs.bitwarden-cli.drvPath)"
    mbp2_xcodebuild="$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp2.pkgs.xcodebuild.outPath)"
    nix derivation show "$mbp2_drv" \
      | jq -e --arg path "$mbp2_xcodebuild" '
          .derivations
          | to_entries[0].value.env.nativeBuildInputs
          | split(" ")
          | index($path) != null
        '

    test "$(nix eval --raw --impure --expr '
      let
        flake = builtins.getFlake (toString ./.);
        locked = flake.inputs.nixpkgs.legacyPackages.x86_64-linux.bitwarden-cli.drvPath;
        overlay = import ./overlays { inputs = flake.inputs; };
        overlaid = (import flake.inputs.nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay ];
        }).bitwarden-cli.drvPath;
      in
      if locked == overlaid then "unchanged" else throw "Linux Bitwarden changed"
    ')" = "unchanged"

Expected: both jq assertions print true and exit 0, and the Linux derivation remains identical to locked Nixpkgs.

- [ ] **Step 5: Build both corrected Darwin packages and the canonical gate**

Run:

    test "$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.bitwarden-cli.version)" = "2026.4.2"
    test "$(nix eval --raw --no-update-lock-file \
      .#darwinConfigurations.mbp2.pkgs.bitwarden-cli.version)" = "2026.4.2"
    nix build --no-link --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.bitwarden-cli
    nix build --no-link --no-update-lock-file \
      .#darwinConfigurations.mbp2.pkgs.bitwarden-cli
    just check
    git diff --exit-code -- flake.lock
    git diff --check
    git diff --cached --quiet -- hosts/mbp2/home.nix

Expected: both package builds and just check exit 0; versions remain 2026.4.2; the lock and protected host path have no patch.

- [ ] **Step 6: Commit and verify the shared repair**

Run:

    git commit -m "fix: provide xcodebuild to Bitwarden on Darwin"
    nix build --no-link --no-update-lock-file \
      .#darwinConfigurations.mbp.pkgs.bitwarden-cli
    nix build --no-link --no-update-lock-file \
      .#darwinConfigurations.mbp2.pkgs.bitwarden-cli
    just check
    test -z "$(git status --short)"

Expected: the commit contains only overlays/bitwarden-cli.nix; both committed package outputs and the canonical gate pass; the implementation worktree is clean.

---

### Task 2: Advance the Revised Shared Tip Through legacy-intel

**Files:** none

**Interfaces:**

- Consumes: the reviewed Task 1 commit on phase1/nix-fleet-modernization and the existing legacy worktree at /Users/wm/nix-config/.worktrees/legacy-intel.
- Produces: /tmp/nix-fleet-phase-1-shared-tip and local branch legacy-intel pointing at the reviewed correction, while retaining exactly the staged README modification and update-workflow deletion.

- [ ] **Step 1: Record the revised shared tip and legacy staged fingerprint**

Run:

    shared_tip="$(git -C /Users/wm/nix-config/.worktrees/nix-fleet-phase-1 rev-parse HEAD)"
    printf '%s\n' "$shared_tip" >/tmp/nix-fleet-phase-1-shared-tip
    legacy_patch_before="$(
      git -C /Users/wm/nix-config/.worktrees/legacy-intel \
        diff --cached --binary \
        | shasum -a 256 \
        | awk '{print $1}'
    )"
    printf '%s\n' "$legacy_patch_before" > \
      /tmp/nix-fleet-phase-1-legacy-patch-sha
    test "$(git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      diff --cached --name-only)" = "$(
        printf '%s\n' \
          .github/workflows/update-flake.yml \
          README.md
      )"
    test -z "$(git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      diff --name-only)"

Expected: the revised shared tip is recorded and exactly the two Task 5 paths are staged with no unstaged legacy patch.

- [ ] **Step 2: Fast-forward the legacy worktree**

Run:

    shared_tip="$(cat /tmp/nix-fleet-phase-1-shared-tip)"
    git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      merge --ff-only "$shared_tip"
    test "$(git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      rev-parse HEAD)" = "$shared_tip"

Expected: legacy-intel fast-forwards without a merge commit or conflict.

- [ ] **Step 3: Prove the staged legacy policy patch is unchanged**

Run:

    legacy_patch_before="$(
      cat /tmp/nix-fleet-phase-1-legacy-patch-sha
    )"
    legacy_patch_after="$(
      git -C /Users/wm/nix-config/.worktrees/legacy-intel \
        diff --cached --binary \
        | shasum -a 256 \
        | awk '{print $1}'
    )"
    test "$legacy_patch_after" = "$legacy_patch_before"
    test "$(git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      diff --cached --name-only)" = "$(
        printf '%s\n' \
          .github/workflows/update-flake.yml \
          README.md
      )"
    test -z "$(git -C /Users/wm/nix-config/.worktrees/legacy-intel \
      diff --name-only)"
    test -f /Users/wm/nix-config/.worktrees/legacy-intel/overlays/bitwarden-cli.nix

Expected: the before/after staged checksums match, only the two Task 5 paths remain staged, and the shared overlay is present.

- [ ] **Step 4: Recheck local-only safety guards**

Run:

    test -z "$(git tag --list legacy-intel-26.05-baseline)"
    test "$(
      git -C /Users/wm/nix-config diff -- hosts/mbp2/home.nix \
        | shasum -a 256 \
        | awk '{print $1}'
    )" = "9cde3794bde391a3e48aaaf0a98dc7477f1ef78326c89dfd030556f7932796a0"
    git -C /Users/wm/nix-config diff --cached --quiet -- hosts/mbp2/home.nix
    test "$(git -C /Users/wm/nix-config diff --name-only)" = \
      "hosts/mbp2/home.nix"

Expected: the baseline tag remains absent, the protected patch is unchanged and unstaged, and no ref has been pushed or configuration activated.

After this task's review, resume Task 5 of the Phase 1 plan at its complete legacy gate. The baseline commit and tag remain forbidden until the exact Intel system build succeeds.
