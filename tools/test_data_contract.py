"""Reference check of the synthetic data-contract fixtures against docs/methodology/DATA_CONTRACT.md.

This is an independent reading of the contract used to keep the fixtures and their
hand-computed expectations consistent. It is not the toolkit's import routine.
"""
from __future__ import annotations

import calendar
import json
import re
import unittest
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "tests" / "fixtures" / "data_contract"
EXPECTED = ROOT / "tests" / "expected" / "data_contract"

ACCOUNT_FIELDS = ["as_of_date", "account_id", "segment", "currency", "balance",
                  "customer_rate", "indexed", "open_date", "close_date"]
REQUIRED = {"as_of_date", "account_id", "segment", "currency", "balance", "indexed"}
RATE_FIELDS = ["as_of_date", "rate_id", "currency", "tenor_months", "rate"]
SEGMENTS = {"RET_TX", "RET_NTX", "WHS_NFC"}
ISO_DATE = re.compile(r"^(\d{4})-(\d{2})-(\d{2})$")
ACCOUNT_ID = re.compile(r"^[A-Za-z0-9_-]{1,32}$")
CURRENCY = re.compile(r"^[A-Z]{3}$")
BALANCE = re.compile(r"^-?\d+(\.\d{1,4})?$")
RATE = re.compile(r"^-?\d+(\.\d{1,8})?$")
RATE_BOUNDS = (-0.05, 0.25)
OUTLIER_RATIO = 10.0


def parse_date(text: str) -> date | None:
    match = ISO_DATE.match(text)
    if not match:
        return None
    try:
        return date(*map(int, match.groups()))
    except ValueError:
        return None


def is_month_end(day: date) -> bool:
    return day.day == calendar.monthrange(day.year, day.month)[1]


def month_index(day: date) -> int:
    return day.year * 12 + day.month - 1


def row_error(row: dict[str, str]) -> str | None:
    """First failing row rule, in the contract's order."""
    if any(not row[name] for name in REQUIRED):
        return "E03"
    as_of = parse_date(row["as_of_date"])
    opened = parse_date(row["open_date"]) if row["open_date"] else None
    closed = parse_date(row["close_date"]) if row["close_date"] else None
    if (as_of is None or not is_month_end(as_of)
            or (row["open_date"] and opened is None) or (row["close_date"] and closed is None)):
        return "E02"
    rate_ok = not row["customer_rate"] or (
        RATE.match(row["customer_rate"])
        and RATE_BOUNDS[0] <= float(row["customer_rate"]) <= RATE_BOUNDS[1])
    if (not ACCOUNT_ID.match(row["account_id"]) or not BALANCE.match(row["balance"])
            or not rate_ok or row["indexed"] not in {"0", "1"}):
        return "E04"
    if row["segment"] not in SEGMENTS:
        return "E06"
    if not CURRENCY.match(row["currency"]):
        return "E07"
    if float(row["balance"]) < 0:
        return "E09"
    if (opened and opened > as_of) or (opened and closed and closed < opened):
        return "E11"
    if closed and as_of > closed:
        return "E10"
    return None


def read_accounts(path: Path) -> tuple[list[tuple[int, dict[str, str]]], list[dict]]:
    lines = path.read_text(encoding="ascii").splitlines()
    if lines[0].split(",") != ACCOUNT_FIELDS:
        return [], [{"line": 1, "code": "E01"}]
    rows, errors, seen, currency = [], [], set(), {}
    for number, line in enumerate(lines[1:], 2):
        values = line.split(",")
        if len(values) != len(ACCOUNT_FIELDS):
            errors.append({"line": number, "code": "E01"})
            continue
        row = dict(zip(ACCOUNT_FIELDS, values))
        code = row_error(row)
        key = (row["as_of_date"], row["account_id"])
        if code is None and key in seen:
            code = "E05"
        if code is None and currency.setdefault(row["account_id"], row["currency"]) != row["currency"]:
            code = "E08"
        if code:
            errors.append({"line": number, "code": code})
        else:
            seen.add(key)
            rows.append((number, row))
    return rows, errors


def warnings_and_totals(rows, first: date, last: date) -> tuple[list[dict], list[dict]]:
    warnings, history = [], {}
    for _, row in rows:
        as_of = parse_date(row["as_of_date"])
        if not first <= as_of <= last:
            warnings.append({"code": "W06", "account_id": row["account_id"], "as_of_date": row["as_of_date"]})
            continue
        history.setdefault(row["account_id"], []).append(row)
    totals: dict[tuple[str, str, str], list] = {}
    for account, observed in sorted(history.items()):
        observed.sort(key=lambda r: r["as_of_date"])
        previous = None
        for row in observed:
            as_of = parse_date(row["as_of_date"])
            balance = float(row["balance"])
            cell = totals.setdefault((row["as_of_date"], row["segment"], row["currency"]), [0, 0.0])
            cell[0] += 1
            cell[1] += balance
            if balance == 0:
                warnings.append({"code": "W02", "account_id": account, "as_of_date": row["as_of_date"]})
            if previous is not None:
                gap = month_index(as_of) - month_index(parse_date(previous["as_of_date"]))
                for missing in range(1, gap):
                    index = month_index(parse_date(previous["as_of_date"])) + missing
                    year, month = divmod(index, 12)
                    day = date(year, month + 1, calendar.monthrange(year, month + 1)[1])
                    warnings.append({"code": "W01", "account_id": account, "as_of_date": day.isoformat()})
                if row["segment"] != previous["segment"]:
                    warnings.append({"code": "W03", "account_id": account, "as_of_date": row["as_of_date"]})
                before = float(previous["balance"])
                if gap == 1 and before > 0 and balance > 0 and not (
                        1 / OUTLIER_RATIO <= balance / before <= OUTLIER_RATIO):
                    warnings.append({"code": "W04", "account_id": account, "as_of_date": row["as_of_date"]})
            previous = row
        if parse_date(observed[-1]["as_of_date"]) < last and not observed[-1]["close_date"]:
            warnings.append({"code": "W05", "account_id": account, "as_of_date": observed[-1]["as_of_date"]})
    total_rows = [{"as_of_date": d, "segment": s, "currency": c, "accounts": n, "balance": round(b, 2)}
                  for (d, s, c), (n, b) in totals.items()]
    order = lambda w: (w["code"], w["account_id"], w["as_of_date"])
    return sorted(warnings, key=order), sorted(total_rows, key=lambda t: (t["as_of_date"], t["segment"], t["currency"]))


class DataContractFixtures(unittest.TestCase):
    def test_valid_panel_matches_hand_computed_expectations(self) -> None:
        expected = json.loads((EXPECTED / "accounts_summary.json").read_text(encoding="utf-8"))
        rows, errors = read_accounts(ROOT / expected["fixture"])
        self.assertEqual(errors, expected["errors"])
        self.assertEqual(len(rows), expected["rows"])
        self.assertEqual(len({r["account_id"] for _, r in rows}), expected["accounts"])
        warnings, totals = warnings_and_totals(
            rows, parse_date(expected["window"]["first"]), parse_date(expected["window"]["last"]))
        order = lambda w: (w["code"], w["account_id"], w["as_of_date"])
        self.assertEqual(warnings, sorted(expected["warnings"], key=order))
        want = sorted(expected["totals"], key=lambda t: (t["as_of_date"], t["segment"], t["currency"]))
        self.assertEqual([{k: v for k, v in t.items() if k != "balance"} for t in totals],
                         [{k: v for k, v in t.items() if k != "balance"} for t in want])
        for got, ref in zip(totals, want):
            self.assertAlmostEqual(got["balance"], ref["balance"], delta=expected["balance_tolerance"])

    def test_segment_totals_reconcile_to_panel(self) -> None:
        rows, _ = read_accounts(FIXTURES / "accounts.csv")
        _, totals = warnings_and_totals(rows, date(2025, 1, 31), date(2025, 6, 30))
        for as_of in sorted({r["as_of_date"] for _, r in rows}):
            for currency in ("EUR", "USD"):
                panel = sum(float(r["balance"]) for _, r in rows
                            if r["as_of_date"] == as_of and r["currency"] == currency)
                segments = sum(t["balance"] for t in totals
                               if t["as_of_date"] == as_of and t["currency"] == currency)
                self.assertAlmostEqual(panel, segments, delta=0.005)

    def test_invalid_panel_reports_one_finding_per_rule(self) -> None:
        expected = json.loads((EXPECTED / "accounts_invalid_findings.json").read_text(encoding="utf-8"))
        rows, errors = read_accounts(ROOT / expected["fixture"])
        self.assertEqual(errors, expected["errors"])
        self.assertEqual({e["code"] for e in errors},
                         {"E02", "E03", "E04", "E05", "E06", "E07", "E08", "E09", "E10", "E11"})

    def test_wrong_header_stops_the_import(self) -> None:
        import tempfile
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "accounts.csv"
            path.write_text("as_of_date,account_id\n2025-01-31,A001\n", encoding="ascii")
            self.assertEqual(read_accounts(path), ([], [{"line": 1, "code": "E01"}]))

    def test_market_rates_fixture_follows_the_contract(self) -> None:
        lines = (FIXTURES / "market_rates.csv").read_text(encoding="ascii").splitlines()
        self.assertEqual(lines[0].split(","), RATE_FIELDS)
        keys = set()
        for line in lines[1:]:
            row = dict(zip(RATE_FIELDS, line.split(",")))
            as_of = parse_date(row["as_of_date"])
            self.assertTrue(as_of and is_month_end(as_of), line)
            self.assertRegex(row["currency"], CURRENCY)
            self.assertRegex(row["tenor_months"], r"^[1-9]\d*$")
            self.assertRegex(row["rate"], RATE)
            self.assertTrue(RATE_BOUNDS[0] <= float(row["rate"]) <= RATE_BOUNDS[1], line)
            self.assertNotIn((row["as_of_date"], row["rate_id"]), keys)
            keys.add((row["as_of_date"], row["rate_id"]))

    def test_fixtures_are_ascii_with_lf_endings(self) -> None:
        for path in sorted(FIXTURES.glob("*.csv")):
            data = path.read_bytes()
            self.assertNotIn(b"\r", data, path.name)
            data.decode("ascii")


if __name__ == "__main__":
    unittest.main()
