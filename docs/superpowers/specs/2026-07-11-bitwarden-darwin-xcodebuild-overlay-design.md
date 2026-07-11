# Bitwarden Darwin `xcodebuild` Overlay Design

## Context

The Phase 1 legacy verification build reaches the locked Nixpkgs
`bitwarden-cli-2026.4.2` derivation on `x86_64-darwin`. Its native dependency
set contains `xcbuild.xcrun`, but `node-gyp` directly executes
`xcodebuild -version` while rebuilding `msgpackr-extract`. Because the full
`xcbuild` output is absent from the derivation's `PATH`, the build fails with
`FileNotFoundError: xcodebuild`.

An ephemeral override that added only `pkgs.xcodebuild` built the unchanged
Bitwarden derivation successfully. This isolates the failure to one missing
native build input rather than the repository's host composition, package
version, or lock state.

## Decision

Add one auto-discovered shared overlay, `overlays/bitwarden-cli.nix`. On Darwin
only, it overrides the locked `bitwarden-cli` derivation and appends
`xcodebuild` to its existing `nativeBuildInputs`.

The overlay will:

- use `prev.bitwarden-cli.overrideAttrs` so it extends the locked package
  without recursion;
- preserve every existing native build input and append `prev.xcodebuild`
  only when `prev.stdenv.hostPlatform.isDarwin`;
- leave Linux derivations unchanged;
- preserve the Bitwarden version, source, npm dependency hash, runtime
  closure, and user-facing package interface; and
- rely on the existing deterministic overlay auto-discovery without changing
  `overlays/default.nix`.

The correction belongs on the shared lineage because the Nixpkgs defect is
Darwin-wide, not Intel-specific. After review, the shared-tip marker and
`legacy-intel` branch will fast-forward through the correction before the
legacy policy commit resumes.

## Alternatives Considered

1. **Legacy-only overlay:** smaller immediate branch scope, but it duplicates
   Darwin package behavior and leaves the Apple-Silicon line dependent on
   binary-cache availability. Rejected in favor of one shared repair.
2. **Remove `bitwarden-cli` from the Intel host:** avoids the failing build but
   changes the preserved workstation composition. Rejected.
3. **Install or expose host Xcode:** the Nix derivation constructs its own
   `PATH`, and the host `/usr/bin/xcodebuild` is not a declared build input.
   This would be impure and would not repair reproducibility. Rejected.

## Verification

The existing failed system build and Bitwarden log provide RED evidence. The
ephemeral override build provides focused proof of the proposed dependency.
The committed correction must then pass:

1. evaluation showing the corrected Darwin Bitwarden derivation contains the
   full `xcodebuild` output;
2. focused `bitwarden-cli` builds for the declared Darwin configurations;
3. the authoritative `just check` gate;
4. task-scoped spec and quality review of the one-file overlay commit;
5. fast-forwarding `legacy-intel` to the revised shared tip without capturing
   its staged policy change; and
6. the exact Task 5 Intel system build before and after the legacy policy
   commit, followed by local tag creation only after both builds pass.

No configuration is activated, no lock node is updated, no ref is pushed, and
the protected source-worktree SOPS patch remains unchanged and unstaged.
