"""Regressions for Codex findings on PRs #1 and #15; no Excel execution."""
from __future__ import annotations

import csv
import json
import os
import shutil
import subprocess
import tempfile
import textwrap
import unittest
import zipfile
from pathlib import Path

from check_source import check_workbook

ROOT = Path(__file__).resolve().parents[1]
CORE_PARTS = {
    "[Content_Types].xml": '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"/>',
    "_rels/.rels": '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
    "xl/workbook.xml": '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"/>',
    "xl/_rels/workbook.xml.rels": '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
}


class WorkbookPackageTests(unittest.TestCase):
    def check_parts(self, parts):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with zipfile.ZipFile(root / "template.xlsx", "w") as archive:
                for name, value in parts.items():
                    archive.writestr(name, value)
            return check_workbook(root, "template.xlsx")

    def test_empty_archive_rejected(self):
        self.assertTrue(self.check_parts({}))

    def test_each_required_part_is_required(self):
        for missing in CORE_PARTS:
            with self.subTest(missing=missing):
                findings = self.check_parts({k: v for k, v in CORE_PARTS.items() if k != missing})
                self.assertIn(missing, " ".join(findings))

    def test_structural_fixture_accepted_without_claiming_excel_validity(self):
        # Deliberately a structural fixture, not a distributable Excel workbook.
        self.assertEqual(self.check_parts(CORE_PARTS), [])

    def test_malformed_core_xml_rejected(self):
        self.assertTrue(self.check_parts({**CORE_PARTS, "xl/workbook.xml": "<broken"}))

    def test_forbidden_parts_still_rejected(self):
        for name in ("xl/vbaProject.bin", "docProps/core.xml"):
            with self.subTest(name=name):
                self.assertTrue(self.check_parts({**CORE_PARTS, name: "forbidden"}))

    def test_corruption_outside_core_parts_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "template.xlsx"
            with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_STORED) as archive:
                for name, value in CORE_PARTS.items():
                    archive.writestr(name, value)
                archive.writestr("xl/worksheets/sheet1.xml", b"UNIQUE_PAYLOAD_FOR_CRC_TEST")
            original = path.read_bytes()
            corrupted = original.replace(b"UNIQUE_PAYLOAD_FOR_CRC_TEST", b"BROKEN_PAYLOAD_FOR_CRC_TEST")
            self.assertNotEqual(original, corrupted)
            path.write_bytes(corrupted)
            self.assertIn("corrupt", " ".join(check_workbook(root, path.name)))


class LabelDefaultsTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which("node"), "Node is optional for local Python-only checks")
    def test_commands_without_policy(self):
        for script, arguments in (("labels-sync.mjs", ["--mode", "validate"]),
                                  ("labels-drift.mjs", ["--self-test"])):
            with self.subTest(script=script):
                result = subprocess.run(["node", str(ROOT / ".github/scripts" / script), *arguments],
                                        cwd=ROOT, capture_output=True, text=True, timeout=60)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class TrafficMetricTests(unittest.TestCase):
    def test_old_and_current_schema_and_same_day_rerun(self):
        workflow = (ROOT / ".github/workflows/daily-traffic.yml").read_text()
        build = workflow.split("      - name: Build CSV history\n", 1)[1]
        source = textwrap.dedent(build.split("          python3 << 'PY'\n", 1)[1]
                                 .split("          PY\n", 1)[0])
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fixtures = {
                "views": {"count": 5, "uniques": 3, "views": []},
                "clones": {"count": 2, "uniques": 1, "clones": []},
                "referrers": [], "paths": [],
                "repo": {"stargazers_count": 0, "open_issues_count": 7},
            }
            for name, value in fixtures.items():
                (root / (name + ".json")).write_text(json.dumps(value))
            (root / "data").mkdir()
            history = root / "data/traffic.csv"
            history.write_text("snapshot_date,open_issues\n2000-01-01,12\n")
            source = source.replace('"/tmp/', json.dumps(str(root) + "/")[:-1])
            previous = Path.cwd()
            try:
                os.chdir(root)
                exec(compile(source, "daily-traffic-build", "exec"), {})
                exec(compile(source, "daily-traffic-build", "exec"), {})
            finally:
                os.chdir(previous)
            with history.open(newline="") as handle:
                reader = csv.DictReader(handle)
                rows = list(reader)
                self.assertNotIn("open_issues", reader.fieldnames)
                self.assertIn("open_issues_and_prs", reader.fieldnames)
            self.assertEqual(len(rows), 2)
            self.assertEqual(rows[0]["open_issues_and_prs"], "12")
            self.assertEqual(rows[1]["open_issues_and_prs"], "7")
            self.assertEqual(rows[1]["views_14d"], "5")


if __name__ == "__main__":
    unittest.main()
