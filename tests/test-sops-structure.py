#!/usr/bin/env python3
"""Focused, value-safe regressions for scripts/validate-sops.py."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_sops", ROOT / "scripts/validate-sops.py")
assert SPEC and SPEC.loader
VALIDATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VALIDATOR)

RECIPIENT = "age1testrecipient"
ENCRYPTED = "ENC[AES256_GCM,data:Y2lwaGVy,iv:aXY=,tag:dGFn,type:str]"
AGE_ENCRYPTED = "-----BEGIN AGE ENCRYPTED FILE-----\nZmFrZQ==\n-----END AGE ENCRYPTED FILE-----"


def policy_yaml(recipient: str = RECIPIENT) -> str:
    return f"""\
keys:
  - &main-key {recipient}
creation_rules:
  - path_regex: secrets/.*\\.yaml$
    key_groups:
      - age:
          - *main-key
"""


def secret_yaml(*, value: str = ENCRYPTED, recipient: str = RECIPIENT, mac: str = ENCRYPTED) -> str:
    return f"""\
git-userName: {value}
git-userEmail: {ENCRYPTED}
git-signingKey-test: {ENCRYPTED}
ssh-config-test: {ENCRYPTED}
sops:
  age:
    - recipient: {recipient}
      enc: |-
        {AGE_ENCRYPTED.replace(chr(10), chr(10) + '        ')}
  lastmodified: "2026-01-02T03:04:05Z"
  mac: {mac}
  unencrypted_suffix: _unencrypted
  version: 3.11.0
"""


class SopsStructureTests(unittest.TestCase):
    expected = {
        "git-userName",
        "git-userEmail",
        "git-signingKey-test",
        "ssh-config-test",
    }

    def validate(self, secrets: str, policy: str | None = None) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            secret_path = root / "secrets.yaml"
            policy_path = root / ".sops.yaml"
            secret_path.write_text(secrets, encoding="utf-8")
            policy_path.write_text(policy or policy_yaml(), encoding="utf-8")
            VALIDATOR.validate(
                secret_path,
                policy_path,
                self.expected,
                "secrets/secrets.yaml",
            )

    def test_valid_structure(self) -> None:
        self.validate(secret_yaml())

    def test_rejects_plaintext_without_echoing_it(self) -> None:
        sentinel = "DO-NOT-PRINT-THIS-VALUE"
        with self.assertRaises(VALIDATOR.ValidationError) as raised:
            self.validate(secret_yaml(value=sentinel))
        self.assertIn("plaintext", str(raised.exception))
        self.assertNotIn(sentinel, str(raised.exception))

    def test_requires_every_declared_key(self) -> None:
        self.expected = set(self.expected) | {"missing-host-key"}
        with self.assertRaisesRegex(VALIDATOR.ValidationError, "missing declared keys: missing-host-key"):
            self.validate(secret_yaml())

    def test_allows_encrypted_keys_for_hosts_on_other_supported_branches(self) -> None:
        extra = secret_yaml().replace(
            f"sops:\n",
            f"git-signingKey-other-host: {ENCRYPTED}\nsops:\n",
        )
        self.validate(extra)

    def test_rejects_malformed_mac(self) -> None:
        with self.assertRaisesRegex(VALIDATOR.ValidationError, "MAC is missing or malformed"):
            self.validate(secret_yaml(mac="not-an-encrypted-mac"))

    def test_rejects_malformed_age_envelope(self) -> None:
        malformed = secret_yaml().replace(
            "-----END AGE ENCRYPTED FILE-----",
            "missing-age-footer",
        )
        with self.assertRaisesRegex(VALIDATOR.ValidationError, "malformed encrypted key"):
            self.validate(malformed)

    def test_requires_recipient_parity(self) -> None:
        with self.assertRaisesRegex(VALIDATOR.ValidationError, "recipient parity failed"):
            self.validate(secret_yaml(recipient="age1differentrecipient"))

    def test_rejects_duplicate_yaml_keys(self) -> None:
        duplicate = secret_yaml().replace(
            f"git-userEmail: {ENCRYPTED}\n",
            f"git-userEmail: {ENCRYPTED}\ngit-userEmail: {ENCRYPTED}\n",
        )
        with self.assertRaisesRegex(VALIDATOR.ValidationError, "duplicate mapping key"):
            self.validate(duplicate)

    def test_rejects_unhashable_yaml_keys_without_type_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "invalid.yaml"
            path.write_text("? [invalid]\n: value\n", encoding="utf-8")
            with self.assertRaisesRegex(VALIDATOR.ValidationError, "invalid mapping key"):
                VALIDATOR.load_yaml(path)

    def test_rejects_unknown_plaintext_sops_metadata_without_echoing_it(self) -> None:
        sentinel = "DO-NOT-PRINT-METADATA"
        malformed = secret_yaml().replace("sops:\n", f"sops:\n  unexpected: {sentinel}\n")
        with self.assertRaises(VALIDATOR.ValidationError) as raised:
            self.validate(malformed)
        self.assertIn("unsupported fields", str(raised.exception))
        self.assertNotIn(sentinel, str(raised.exception))


if __name__ == "__main__":
    unittest.main(verbosity=2)
