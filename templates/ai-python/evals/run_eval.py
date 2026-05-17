#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console


def load_cases(path: Path) -> list[dict]:
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def score_case(output: str, must_contain: list[str]) -> bool:
    text = output.lower()
    return all(term.lower() in text for term in must_contain)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="gpt-5-mini")
    parser.add_argument("--cases", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    load_dotenv()
    client = OpenAI()
    console = Console()
    cases = load_cases(args.cases)
    results = []

    for case in cases:
        response = client.responses.create(
            model=args.model,
            input=case["input"],
        )
        output = response.output_text
        passed = score_case(output, case["must_contain"])
        results.append({
            "id": case["id"],
            "passed": passed,
            "output": output,
        })
        console.print(f"{case['id']}: {'PASS' if passed else 'FAIL'}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(json.dumps(row) for row in results) + "\n")

    failures = [row for row in results if not row["passed"]]
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
