#!/usr/bin/env python3
"""Regression checks for CI pinning and validation topology."""

from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_ACTIONS = {
    "actions/checkout": ("d23441a48e516b6c34aea4fa41551a30e30af803", "v6"),
    "DeterminateSystems/nix-installer-action": (
        "ef8a148080ab6020fd15196c2084a2eea5ff2d25",
        "v22",
    ),
    "peter-evans/create-pull-request": (
        "5f6978faf089d4d20b00c7766989d076bb2fc7f1",
        "v8",
    ),
}


class CiValidationTests(unittest.TestCase):
    def test_every_action_is_full_sha_pinned_with_version_comment(self) -> None:
        uses_pattern = re.compile(
            r"^\s*-?\s*uses:\s*([^@\s]+)@([0-9a-f]{40})\s+#\s+(v\d+)\s*$"
        )
        seen: set[str] = set()
        for workflow in sorted((ROOT / ".github/workflows").glob("*.yml")):
            for line_number, line in enumerate(workflow.read_text(encoding="utf-8").splitlines(), 1):
                if "uses:" not in line:
                    continue
                match = uses_pattern.match(line)
                self.assertIsNotNone(
                    match,
                    f"{workflow.relative_to(ROOT)}:{line_number}: action must use a full SHA and version comment",
                )
                assert match
                action, sha, version = match.groups()
                self.assertIn(action, EXPECTED_ACTIONS, f"unexpected action {action}")
                self.assertEqual((sha, version), EXPECTED_ACTIONS[action], action)
                seen.add(action)
        self.assertEqual(seen, set(EXPECTED_ACTIONS))

    def test_ci_has_native_matrix_one_canonical_run_and_all_systems_gate(self) -> None:
        ci = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        self.assertRegex(ci, r"(?m)^\s+matrix:")
        self.assertIn("ubuntu-latest", ci)
        self.assertIn("macos-latest", ci)
        self.assertNotIn("id-token: write", ci)
        self.assertEqual(ci.count("just check\n"), 1, "canonical just check must run once")
        justfile = (ROOT / "justfile").read_text(encoding="utf-8")
        self.assertEqual(
            justfile.count("nix flake check . --all-systems --no-build --no-update-lock-file"),
            1,
            "canonical validation must contain one all-systems no-build gate",
        )
        self.assertIn("nix flake check . --no-update-lock-file --print-build-logs", justfile)
        self.assertIn(
            "check:\n    nix develop . --no-update-lock-file --command just _check",
            justfile,
        )
        self.assertRegex(justfile, r"(?m)^_check:\n(?:(?:    .*)?\n)*    just check-all-systems$")
        update = (ROOT / ".github/workflows/update-flake.yml").read_text(encoding="utf-8")
        self.assertNotIn("id-token: write", update)
        self.assertIn("persist-credentials: false", update)
        self.assertIn("token: ${{ github.token }}", update)

    def test_template_validator_has_closed_inventory_and_temporary_lock_policy(self) -> None:
        validator = (ROOT / "scripts/validate-template-flakes.sh").read_text(encoding="utf-8")
        match = re.search(r"templates=\(([^)]*)\)", validator)
        self.assertIsNotNone(match)
        assert match
        self.assertEqual(
            set(match.group(1).split()),
            {"node", "python", "ai-python", "rust", "go"},
        )
        self.assertIn('tmp_root="$(mktemp -d)"', validator)
        self.assertIn('nix flake lock "$work_dir"', validator)
        self.assertIn("--all-systems --no-build --no-update-lock-file", validator)
        for name in ("node", "python", "ai-python", "rust", "go"):
            self.assertFalse((ROOT / "templates" / name / "flake.lock").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
