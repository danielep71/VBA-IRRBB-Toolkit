"""Offline coverage of metadata reconciliation; no GitHub calls."""
from __future__ import annotations

import copy
import importlib.util
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("issue_metadata", Path(__file__).resolve().parents[1]
                                             / ".github/scripts/issue-metadata.py")
policy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(policy)


class IssueMetadataTests(unittest.TestCase):
    def simulate(self, issue, milestone_state="open"):
        current = copy.deepcopy(issue)
        calls = []

        def api(endpoint, method="GET", payload=None, paginate=False):
            calls.append((endpoint, method, payload))
            if "/milestones/" in endpoint:
                return {"number": 1, "state": milestone_state}
            if method == "GET":
                return copy.deepcopy(current)
            if endpoint.endswith("/assignees"):
                current["assignees"] += [{"login": name} for name in payload["assignees"]]
            elif endpoint.endswith("/labels"):
                current["labels"] += [{"name": name} for name in payload["labels"]]
            elif method == "DELETE":
                current["labels"] = [label for label in current["labels"]
                                     if label["name"] != endpoint.rsplit("/", 1)[1]]
            elif method == "PATCH":
                current["milestone"] = {"number": payload["milestone"]}
            return None

        with patch.object(policy, "api", side_effect=api):
            policy.reconcile("owner/repo", 10, 1)
        return current, calls

    def test_open_and_closed_issues_get_missing_metadata(self):
        for state in ("open", "closed"):
            result, _ = self.simulate({"state": state, "assignees": [], "labels": [{"name": "bug"}], "milestone": None})
            self.assertEqual(result, {"state": state, "assignees": [{"login": "danielep71"}],
                                     "labels": [{"name": "bug"}, {"name": "P3"}], "milestone": {"number": 1}})

    def test_conflicting_priorities_keep_highest_and_preserve_existing_milestone(self):
        result, calls = self.simulate({"assignees": [{"login": "danielep71"}, {"login": "other"}],
                                      "labels": [{"name": p} for p in ("P3", "bug", "P1", "P2")],
                                      "milestone": {"number": 99, "state": "closed"}})
        self.assertEqual(result["labels"], [{"name": "bug"}, {"name": "P1"}])
        self.assertEqual(result["milestone"]["number"], 99)
        self.assertEqual(len(result["assignees"]), 2)
        self.assertFalse(any(method in {"POST", "PATCH"} for _, method, _ in calls))

    def test_correct_issue_is_idempotent_and_pr_is_ignored(self):
        issue = {"assignees": [{"login": "danielep71"}], "labels": [{"name": "P2"}], "milestone": {"number": 1}}
        for current in (issue, {"pull_request": {}}):
            result, calls = self.simulate(current)
            self.assertEqual(result, current)
            self.assertTrue(all(method == "GET" for _, method, _ in calls))

    def test_closed_default_milestone_is_rejected(self):
        with self.assertRaisesRegex(RuntimeError, "must be open"):
            self.simulate({"assignees": [{"login": "danielep71"}], "labels": [{"name": "P2"}],
                           "milestone": None}, "closed")


if __name__ == "__main__":
    unittest.main()
