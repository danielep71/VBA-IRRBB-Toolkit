#!/usr/bin/env python3
"""Idempotent bootstrap of the v0.1.0 milestone and issue metadata on trusted CI."""
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

REPO = os.environ["GITHUB_REPOSITORY"]
TOKEN = os.environ["GITHUB_TOKEN"]
API = "https://api.github.com/repos/" + REPO
NAME = "v0.1.0 - Repository foundation"
MARKER = "<!-- milestone: v0.1.0 -->"


def request(method: str, path: str, payload: dict | None = None) -> object:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        API + path,
        data=body,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": "Bearer " + TOKEN,
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "irrrb-repository-bootstrap",
            "Content-Type": "application/json",
        },
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        print(f"GitHub API failed: {method} {path}: HTTP {exc.code}", file=sys.stderr)
        raise


def paged(path: str) -> list[dict]:
    results: list[dict] = []
    page = 1
    while page <= 20:
        separator = "&" if "?" in path else "?"
        current = request("GET", f"{path}{separator}per_page=100&page={page}")
        assert isinstance(current, list)
        results.extend(current)
        if len(current) < 100:
            return results
        page += 1
    raise RuntimeError("Exceeded pagination safety limit")


def main() -> int:
    existing = paged("/milestones?state=all")
    matches = [m for m in existing if m.get("title") == NAME]
    if len(matches) > 1:
        raise RuntimeError("Duplicate milestone titles; manual reconciliation required")
    if matches:
        number = matches[0]["number"]
        print(f"Using existing milestone {NAME} (#{number})")
    else:
        made = request(
            "POST", "/milestones",
            {
                "title": NAME,
                "state": "open",
                "description": (
                    "Foundation only: repository structure, source boundaries, quality gates, "
                    "synthetic-data policy, governance and Excel validation contract. "
                    "No econometric model or validated workbook in this milestone."
                ),
            },
        )
        assert isinstance(made, dict)
        number = made["number"]
        print(f"Created milestone {NAME} (#{number})")

    updated = 0
    for issue in paged("/issues?state=all"):
        if "pull_request" in issue or MARKER not in (issue.get("body") or ""):
            continue
        requested = None
        for line in (issue["body"] or "").splitlines():
            if line.startswith("<!-- issue-labels: ") and line.endswith(" -->"):
                requested = [x.strip() for x in line[len("<!-- issue-labels: "):-len(" -->")].split(",")]
                break
        desired = {"milestone": number}
        if requested:
            desired["labels"] = requested
        if issue.get("milestone", {}) and issue["milestone"]["number"] == number:
            current_labels = {l["name"] for l in issue.get("labels", [])}
            if requested is None or current_labels == set(requested):
                continue
        request("PATCH", f"/issues/{issue['number']}", desired)
        updated += 1
    print(f"Milestone assignment/label reconciliation: {updated} issue(s) updated")
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as fp:
            fp.write(f"## Repository tracking bootstrap\nMilestone: **{NAME}** (#{number})\n\nUpdated issues: **{updated}**\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
