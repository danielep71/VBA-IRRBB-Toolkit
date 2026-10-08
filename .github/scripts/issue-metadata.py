"""Enforce the owner's issue policy with narrow API updates and read-back checks."""
from __future__ import annotations

import json
import os
import subprocess
import sys

PRIORITIES = ("P1", "P2", "P3")
OWNER = "danielep71"


def api(endpoint, method="GET", payload=None, paginate=False):
    command = ["gh", "api", endpoint, "--method", method]
    if paginate:
        command += ["--paginate", "--slurp"]
    if payload is not None:
        command += ["--input", "-"]
    completed = subprocess.run(command, input=json.dumps(payload) if payload is not None else None,
                               capture_output=True, text=True, check=True)
    return json.loads(completed.stdout) if completed.stdout.strip() else None


def desired_priority(issue):
    labels = {label["name"] for label in issue["labels"]}
    return next((priority for priority in PRIORITIES if priority in labels), "P3")


def reconcile(repository, number, default_milestone):
    endpoint = f"repos/{repository}/issues/{number}"
    issue = api(endpoint)
    if "pull_request" in issue:
        return
    if OWNER not in {person["login"] for person in issue["assignees"]}:
        api(endpoint + "/assignees", "POST", {"assignees": [OWNER]})
    priority = desired_priority(issue)
    labels = {label["name"] for label in issue["labels"]}
    if priority not in labels:
        api(endpoint + "/labels", "POST", {"labels": [priority]})
    for other in PRIORITIES:
        if other != priority and other in labels:
            api(endpoint + f"/labels/{other}", "DELETE")
    if issue["milestone"] is None:
        milestone = api(f"repos/{repository}/milestones/{default_milestone}")
        if milestone["state"] != "open":
            raise RuntimeError("Configured default milestone must be open")
        api(endpoint, "PATCH", {"milestone": default_milestone})
    verified = api(endpoint)
    if (OWNER not in {person["login"] for person in verified["assignees"]}
            or verified["milestone"] is None
            or len({label["name"] for label in verified["labels"]} & set(PRIORITIES)) != 1):
        raise RuntimeError(f"Issue #{number}: post-update metadata verification failed")
    print(f"Issue #{number}: owner, milestone and one priority verified")


def main():
    repository = os.environ["GITHUB_REPOSITORY"]
    milestone = int(os.environ.get("ISSUE_MILESTONE_NUMBER", "1"))
    if milestone < 1:
        raise ValueError("ISSUE_MILESTONE_NUMBER must be positive")
    number = os.environ.get("ISSUE_NUMBER", "")
    if number:
        numbers = [int(number)]
    else:
        pages = api(f"repos/{repository}/issues?state=all&per_page=100", paginate=True)
        numbers = [issue["number"] for page in pages for issue in page if "pull_request" not in issue]
    for number in numbers:
        reconcile(repository, number, milestone)
    return 0


if __name__ == "__main__":
    sys.exit(main())
