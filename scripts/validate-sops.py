#!/usr/bin/env python3
"""Validate SOPS YAML structure without decrypting or displaying values."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

import yaml


class ValidationError(Exception):
    """A secret-safe validation failure."""


class UniqueKeyLoader(yaml.SafeLoader):
    pass


def _construct_mapping(loader: UniqueKeyLoader, node: yaml.MappingNode, deep: bool = False) -> dict[Any, Any]:
    mapping: dict[Any, Any] = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        try:
            duplicate = key in mapping
        except TypeError:
            raise ValidationError("YAML contains an invalid mapping key") from None
        if duplicate:
            raise ValidationError("YAML contains a duplicate mapping key")
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    _construct_mapping,
)

ENC_RE = re.compile(
    r"^ENC\[AES256_GCM,data:[^,\]]*,iv:[^,\]]+,tag:[^,\]]+,type:[^,\]]+\]$"
)
MAC_RE = re.compile(
    r"^ENC\[AES256_GCM,data:[^,\]]+,iv:[^,\]]+,tag:[^,\]]+,type:[^,\]]+\]$"
)
AGE_HEADER = "-----BEGIN AGE ENCRYPTED FILE-----"
AGE_FOOTER = "-----END AGE ENCRYPTED FILE-----"
TIMESTAMP_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")


def load_yaml(path: Path) -> Any:
    try:
        return yaml.load(path.read_text(encoding="utf-8"), Loader=UniqueKeyLoader)
    except ValidationError:
        raise
    except (OSError, UnicodeError, yaml.YAMLError) as exc:
        raise ValidationError(f"cannot parse {path}: {type(exc).__name__}") from None


def require_encrypted_leaves(value: Any, location: str) -> None:
    if isinstance(value, dict):
        if not value:
            raise ValidationError(f"{location} is empty instead of encrypted")
        for key, child in value.items():
            if not isinstance(key, str) or not key:
                raise ValidationError(f"{location} contains an invalid key name")
            require_encrypted_leaves(child, f"{location}.{key}")
        return
    if isinstance(value, list):
        if not value:
            raise ValidationError(f"{location} is empty instead of encrypted")
        for index, child in enumerate(value):
            require_encrypted_leaves(child, f"{location}[{index}]")
        return
    if not isinstance(value, str) or not ENC_RE.fullmatch(value):
        raise ValidationError(f"{location} contains plaintext or malformed encrypted data")


def policy_recipients(policy: Any, logical_path: str) -> set[str]:
    if not isinstance(policy, dict) or not isinstance(policy.get("creation_rules"), list):
        raise ValidationError(".sops.yaml must contain a creation_rules list")

    matching_rule: dict[str, Any] | None = None
    for rule in policy["creation_rules"]:
        if not isinstance(rule, dict):
            raise ValidationError(".sops.yaml contains a malformed creation rule")
        pattern = rule.get("path_regex")
        if not isinstance(pattern, str):
            raise ValidationError(".sops.yaml creation rule is missing path_regex")
        try:
            matches = re.search(pattern, logical_path) is not None
        except re.error:
            raise ValidationError(".sops.yaml contains an invalid path_regex") from None
        if matches:
            matching_rule = rule
            break

    if matching_rule is None:
        raise ValidationError(f".sops.yaml has no creation rule for {logical_path}")

    recipients: list[str] = []
    direct_age = matching_rule.get("age", [])
    if direct_age:
        if not isinstance(direct_age, list):
            raise ValidationError("matching .sops.yaml age recipients must be a list")
        recipients.extend(direct_age)

    groups = matching_rule.get("key_groups", [])
    if groups:
        if not isinstance(groups, list):
            raise ValidationError("matching .sops.yaml key_groups must be a list")
        for group in groups:
            if not isinstance(group, dict):
                raise ValidationError("matching .sops.yaml contains a malformed key group")
            age = group.get("age", [])
            if not isinstance(age, list):
                raise ValidationError("matching .sops.yaml age recipients must be a list")
            recipients.extend(age)

    if not recipients or any(not isinstance(item, str) or not item for item in recipients):
        raise ValidationError("matching .sops.yaml rule has no valid age recipients")
    if len(recipients) != len(set(recipients)):
        raise ValidationError("matching .sops.yaml rule repeats an age recipient")
    return set(recipients)


def encrypted_recipients(metadata: Any) -> set[str]:
    if not isinstance(metadata, dict):
        raise ValidationError("encrypted YAML is missing the sops metadata mapping")
    allowed_metadata_keys = {"age", "lastmodified", "mac", "unencrypted_suffix", "version"}
    if any(not isinstance(key, str) for key in metadata):
        raise ValidationError("sops metadata contains an invalid key name")
    if set(metadata) != allowed_metadata_keys:
        raise ValidationError("sops metadata contains missing or unsupported fields")
    age_entries = metadata.get("age")
    if not isinstance(age_entries, list) or not age_entries:
        raise ValidationError("sops metadata must contain a non-empty age recipient list")

    recipients: list[str] = []
    for entry in age_entries:
        if not isinstance(entry, dict):
            raise ValidationError("sops age metadata contains a malformed entry")
        if set(entry) != {"recipient", "enc"}:
            raise ValidationError("sops age metadata contains missing or unsupported fields")
        recipient = entry.get("recipient")
        encrypted_key = entry.get("enc")
        if not isinstance(recipient, str) or not recipient:
            raise ValidationError("sops age metadata contains an invalid recipient")
        age_lines = encrypted_key.strip().splitlines() if isinstance(encrypted_key, str) else []
        if (
            len(age_lines) < 3
            or age_lines[0] != AGE_HEADER
            or age_lines[-1] != AGE_FOOTER
            or not any(line.strip() for line in age_lines[1:-1])
        ):
            raise ValidationError("sops age metadata contains a malformed encrypted key")
        recipients.append(recipient)

    if len(recipients) != len(set(recipients)):
        raise ValidationError("sops metadata repeats an age recipient")

    mac = metadata.get("mac")
    if not isinstance(mac, str) or not MAC_RE.fullmatch(mac):
        raise ValidationError("sops metadata MAC is missing or malformed")
    if not isinstance(metadata.get("lastmodified"), str) or not TIMESTAMP_RE.fullmatch(metadata["lastmodified"]):
        raise ValidationError("sops metadata lastmodified timestamp is missing or malformed")
    if not isinstance(metadata.get("version"), str) or not VERSION_RE.fullmatch(metadata["version"]):
        raise ValidationError("sops metadata version is missing or malformed")
    if not isinstance(metadata.get("unencrypted_suffix"), str) or not metadata["unencrypted_suffix"]:
        raise ValidationError("sops metadata unencrypted_suffix is missing or malformed")
    return set(recipients)


def validate(secret_path: Path, policy_path: Path, expected_keys: set[str], logical_path: str) -> None:
    document = load_yaml(secret_path)
    policy = load_yaml(policy_path)
    if not isinstance(document, dict):
        raise ValidationError("encrypted YAML root must be a mapping")
    if "sops" not in document:
        raise ValidationError("encrypted YAML is missing sops metadata")

    actual_keys = {key for key in document if key != "sops"}
    if any(not isinstance(key, str) or not key for key in actual_keys):
        raise ValidationError("encrypted YAML contains an invalid top-level key name")
    # The same encrypted file is shared by main and legacy-intel, so keys for
    # hosts declared only on the other supported branch are valid extras.
    if not expected_keys.issubset(actual_keys):
        missing = sorted(expected_keys - actual_keys)
        raise ValidationError(
            "encrypted key-name comparison failed; missing declared keys: " + ", ".join(missing)
        )

    for key in sorted(actual_keys):
        require_encrypted_leaves(document[key], key)

    configured = policy_recipients(policy, logical_path)
    encrypted = encrypted_recipients(document["sops"])
    if configured != encrypted:
        raise ValidationError(
            "age recipient parity failed between encrypted YAML metadata and .sops.yaml"
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--secrets", type=Path, required=True)
    parser.add_argument("--policy", type=Path, required=True)
    parser.add_argument("--expected-keys-json", type=Path, required=True)
    parser.add_argument("--logical-secret-path", default="secrets/secrets.yaml")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        expected = json.loads(args.expected_keys_json.read_text(encoding="utf-8"))
        if not isinstance(expected, list) or any(not isinstance(key, str) or not key for key in expected):
            raise ValidationError("declared secret key evaluation did not return a string list")
        if not expected:
            raise ValidationError("declared secret key evaluation returned no names")
        if len(expected) != len(set(expected)):
            raise ValidationError("declared secret key evaluation returned duplicate names")
        validate(args.secrets, args.policy, set(expected), args.logical_secret_path)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        print(f"sops-structure: input error ({type(exc).__name__})", file=sys.stderr)
        return 1
    except ValidationError as exc:
        print(f"sops-structure: {exc}", file=sys.stderr)
        return 1
    print("sops-structure: key names, encryption envelopes, metadata, and recipients are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
