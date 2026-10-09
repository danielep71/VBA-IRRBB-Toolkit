<div align="center">

# 🧾 Data Contract

### Input data, segmentation and lineage for the IRRBB behavioral models

[![Status](https://img.shields.io/badge/Status-Accepted_(%234)-217346?style=flat-square)](#decisions)
[![Data](https://img.shields.io/badge/Data-synthetic_only-217346?style=flat-square)](../../CONTRIBUTING.md#data-confidentiality-and-provenance)
[![Fixtures](https://img.shields.io/badge/Fixtures-reference--checked-0969da?style=flat-square)](#synthetic-fixtures)

<br>

**One row per account per month end · Stocks, not flows · All-or-nothing import · Every run traceable to its data**

</div>

---

This document is authoritative for **the input datasets, their fields, units and
validation, segmentation and reconciliation, and data lineage**. Units at the
public boundary follow
[`REPOSITORY_STRUCTURE.md`](../REPOSITORY_STRUCTURE.md#parameter-and-units-boundary);
model definitions are in [`README.md`](README.md); validation obligations in
[`VALIDATION_PLAN.md`](VALIDATION_PLAN.md).

> [!IMPORTANT]
> This contract was **accepted by the owner on 2026-10-08 in issue #4**,
> including the [decisions](#decisions) below; see the
> [acceptance record](https://github.com/danielep71/VBA-IRRBB-Toolkit/issues/4#issuecomment-6068526038).
> Audit amendments that affect model interpretation remain open in
> [#26](https://github.com/danielep71/VBA-IRRBB-Toolkit/issues/26). Only synthetic data is ever
> committed or attached. Real data is loaded locally
> and never enters Git, issues or pull requests.

<a id="datasets"></a>

## 🗃️ Datasets

| Dataset | Granularity | Used by |
| --- | --- | --- |
| **Account panel** | One row per account per month end at which the account exists | Stable-amount, decay and rate models; segmentation; reconciliation |
| **Market rates** | One row per rate series per month end | Rate pass-through model and scenarios |

Customer-rate averages, segment balances, cash-outs and log balance changes
are **derived** by the toolkit from these inputs, never supplied as inputs.

<a id="file-format"></a>

## 📄 File format

Both datasets use the same plain, locale-independent CSV subset:

- ASCII text; LF or CRLF line endings; no byte-order mark;
- comma separator, no quoting, no embedded commas or line breaks;
- the first line is the exact header below, fields in the listed order;
- dates as `YYYY-MM-DD`; decimals with `.` and no thousands separator or
  exponent;
- an empty field means *missing*. No sentinel values (`0`, `-999`, `N/A`).

Parsing never uses Excel's locale-dependent conversions (`CDate`, `CDbl` on
text, or sheet auto-formatting), so the same file gives the same result on
every host.

<a id="account-panel"></a>

## 🏦 Account panel

Header:
`as_of_date,account_id,segment,currency,balance,customer_rate,indexed,open_date,close_date`

| Field | Type and format | Unit | Required | Rules |
| --- | --- | --- | :---: | --- |
| `as_of_date` | ISO date | — | ✅ | Calendar month end |
| `account_id` | 1–32 characters `A–Z a–z 0–9 _ -` | — | ✅ | Opaque pseudonymous key; never a real account number |
| `segment` | Code | — | ✅ | One of the [segment codes](#segmentation) |
| `currency` | ISO 4217 code, 3 upper-case letters | — | ✅ | Constant for an account |
| `balance` | Decimal, up to 4 places | Currency units | ✅ | End-of-month **stock**, ≥ 0 |
| `customer_rate` | Decimal, up to 8 places | Decimal per annum | — | Rate paid on the account at month end; −0.05 to 0.25 |
| `indexed` | `0` or `1` | — | ✅ | `1` = contractually indexed to a market rate |
| `open_date` | ISO date | — | — | Not after `as_of_date` |
| `close_date` | ISO date | — | — | Not before `open_date`; no row after it |

The key is (`as_of_date`, `account_id`). A missing `customer_rate` excludes
that account-month from rate-model inputs only. Missing `open_date` means
opened before the data window or unknown.

<a id="market-rates"></a>

## 📈 Market rates

Currency validation requires a versioned, explicit run allowlist of ISO 4217
codes; matching three uppercase letters alone is insufficient. The synthetic
reference checker uses `EUR` and `USD`. Extending that allowlist requires reviewed
configuration and provenance; it does not claim to maintain the full ISO register.
Balances must convert to finite VBA Double values; overflow is `E04`. Aggregate
overflow must also fail the future importer rather than produce an infinite result.
Known non-empty opening/closure dates must be consistent throughout an account's
history (`E11`); an omitted repeat does not erase a known date. A row after any
known closure is `E10`, regardless of file ordering. These consistency checks do
not make future closure information eligible as a predictor.

Header: `as_of_date,rate_id,currency,tenor_months,rate`

| Field | Type and format | Unit | Required | Rules |
| --- | --- | --- | :---: | --- |
| `as_of_date` | ISO date | — | ✅ | Calendar month end |
| `rate_id` | 1–32 characters `A–Z a–z 0–9 _ -` | — | ✅ | Series identifier, e.g. `EUR_1M` |
| `currency` | ISO 4217 code | — | ✅ | Constant for a series |
| `tenor_months` | Positive integer | Months | ✅ | Constant for a series |
| `rate` | Decimal, up to 8 places | Decimal per annum | ✅ | −0.05 to 0.25 |

The key is (`as_of_date`, `rate_id`). Which series a model uses is a run
setting, recorded in the parameter set.

<a id="segmentation"></a>

## 🧩 Segmentation

| Code | Segment |
| --- | --- |
| `RET_TX` | Retail, transactional |
| `RET_NTX` | Retail, non-transactional |
| `WHS_NFC` | Wholesale, non-financial corporate |

These follow the usual supervisory split of non-maturity deposits by
counterparty and transactional use. Adding a segment needs an issue and a
change to this table and the fixtures.

**Assignment is deterministic and supplied, not inferred:** each row carries
its segment, and the toolkit never re-segments an account. An account whose
segment changes between months is a **migration** (warning `W03`): each month
counts in the segment stated for that month, and the model specification
(issue #9) decides how a transition across segments enters estimation.

<a id="reconciliation"></a>

## ⚖️ Reconciliation

After import, the toolkit reports for every (`as_of_date`, `segment`,
`currency`) the number of accounts and the total balance, and checks that:

- totals retain input precision; round only for presentation, after reconciliation;
- the segment totals for each date and currency add up to the panel total for
  that date and currency; and
- if the user supplies control totals, the counts match exactly and balances
  within 0.005 currency units.

Balances in different currencies are never added together. A reconciliation
difference fails the import.

<a id="validation"></a>

## 🚦 Validation and invalid input

**The import is all-or-nothing.** Any error rejects the whole dataset: no
partial dataset is kept, and earlier results stay marked stale. Warnings do not
stop the import; they are reported and recorded in the lineage.

Each row reports its **first** failing rule, checked in the order below, so the
same file always gives the same findings in the same order.

| Code | Error | Rows checked |
| --- | --- | --- |
| `E01` | Header or number of fields does not match the contract | File, then each row |
| `E03` | A required field is empty | Each row |
| `E02` | A date is not a valid ISO date, or `as_of_date` is not a month end | Each row |
| `E04` | A value cannot be parsed or is out of range (ID characters, balance or rate format, rate bounds, `indexed` not `0`/`1`) | Each row |
| `E06` | Unknown segment code | Each row |
| `E07` | Invalid currency code | Each row |
| `E09` | Negative balance | Each row |
| `E11` | Inconsistent known history dates, `open_date` after `as_of_date`, or `close_date` before `open_date` | Each affected row |
| `E10` | Row dated after the account's `close_date` | Each row |
| `E05` | Duplicate (`as_of_date`, `account_id`) | Second and later occurrences |
| `E08` | Account currency or market-series currency/tenor differs from its earlier rows | Each later row |

| Code | Warning | Reported at |
| --- | --- | --- |
| `W01` | **Gap**: account missing in a month between its first and last observation | The missing month |
| `W02` | Zero balance (dormant account) | The row |
| `W03` | **Migration**: segment differs from the previous observation | The row |
| `W04` | **Outlier candidate**: balance more than 10× or less than 1/10 of the previous month, both positive | The later month |
| `W05` | Account stops before the window end without a `close_date` | Its last observation |
| `W06` | Row outside the data window; excluded and counted | The row |

### Missing observations, openings and closures

- A **gap** is missing data, not a zero balance. Transitions that span a gap
  are excluded from estimation; the gap is never filled.
- An account **opens** at its first observation. Its first month has no
  predecessor and enters no transition.
- An account **closes** at its `close_date`; it has no row after that date.
  Closure is a full cash-out in the month it happens.
- An account that **disappears** without a `close_date` (`W05`) is treated as
  closed after its last observation in the accepted baseline. **Implementation
  is blocked on #26:** this rule must distinguish confirmed closure from missing
  extraction and right censoring before generating outcomes or cash-out labels.

### Structural breaks and outliers

The import never alters, removes or winsorizes a value. Outlier candidates are
flagged (`W04`); structural breaks are declared in the run configuration with a
date, segment and reason. How flagged values and breaks enter estimation is a
model setting (issue #9), recorded in the parameter set, never an import side
effect.

<a id="look-ahead"></a>

### Look-ahead prevention

Every run has a data window (first and last month end). Rows outside it are
excluded (`W06`). Backtests and forecasts receive only observations dated on or
before their forecast date; the window is part of the lineage and the
parameter set.

This date filter alone does not establish point-in-time availability. A historical
row may contain a closure learned later (the synthetic panel deliberately includes
such future closure dates). Future closure dates are outcome information, never
predictors at the earlier origin. The availability/vintage rule and missing-versus-
closed decision require the amendment and leakage tests in #26 before modeling.

<a id="dataset-size"></a>

## 📦 Dataset size

A worksheet holds at most 1,048,576 rows, while an account panel easily
exceeds that (50,000 accounts × 120 months = 6 million rows).

**Decided:** the account panel is read from the CSV file by VBA's own file
input, streamed line by line into arrays and aggregates in memory. Worksheets
hold only summaries, parameters and results, never the raw panel. No external
engine is involved ([runtime dependencies](../../INSTALLATION.md#runtime-dependencies)).

Reading a user-selected input file is a file-system access that
[`SECURITY.md`](../../SECURITY.md#security-scope) requires to be agreed in an
issue: read-only, the file the user picks, nothing written next to it. This
issue (#4) is that agreement; `SECURITY.md` is updated in the same change as
the importer.
Memory use and import time for large panels are measured when the importer
exists; nothing about performance is claimed here.

<a id="lineage"></a>

## 🔗 Lineage and reproducible import

Every successful import records, in the workbook and in each parameter set
built from it:

| Item | Content |
| --- | --- |
| Source | File name (no directory path), size in bytes, SHA-256 of the file bytes |
| Counts | Rows read, accepted, excluded by window; accounts; warnings by code |
| Settings | Data window, segment list, rate series selected |
| Code | Toolkit commit SHA |
| Time | Import timestamp with UTC offset |

**Reproducibility:** the same file, settings and commit give the same dataset,
the same findings in the same order and the same fingerprint, on any supported
host. The fingerprint is computed by the toolkit itself, since no external tool
or reference may be used at runtime.

<a id="synthetic-fixtures"></a>

## 🧪 Synthetic fixtures

| File | Content |
| --- | --- |
| [`tests/fixtures/data_contract/accounts.csv`](../../tests/fixtures/data_contract/accounts.csv) | 10 accounts, 6 month ends (Jan–Jun 2025), 51 rows: two currencies, all three segments, an opening mid-window, a closure, a gap, a dormant account, a migration, a disappearance and an outlier |
| [`tests/fixtures/data_contract/accounts_invalid.csv`](../../tests/fixtures/data_contract/accounts_invalid.csv) | One invalid row per error rule `E02`–`E11` |
| [`tests/fixtures/data_contract/market_rates.csv`](../../tests/fixtures/data_contract/market_rates.csv) | `EUR_1M` and `USD_1M`, 6 month ends |
| [`tests/expected/data_contract/accounts_summary.json`](../../tests/expected/data_contract/accounts_summary.json) | Hand-computed totals per date, segment and currency, and every expected warning |
| [`tests/expected/data_contract/accounts_invalid_findings.json`](../../tests/expected/data_contract/accounts_invalid_findings.json) | Expected first error per invalid line |

The fixtures are hand-constructed; the expected values were computed by hand
from the rows. `tools/test_data_contract.py`, run by `python tools/check.py`,
re-reads the fixtures with an independent Python reading of this contract and
fails if fixtures, expectations and rules disagree. The VBA importer, when it
exists, must reproduce the same expected files.

<a id="decisions"></a>

## ✅ Decisions

Accepted by the owner on 2026-10-08 in issue #4.

| # | Decision | Outcome |
| ---: | --- | --- |
| 1 | Input route for the account panel | CSV file streamed by VBA file input, with the read-only file access added to `SECURITY.md` |
| 2 | Segment list | `RET_TX`, `RET_NTX`, `WHS_NFC` |
| 3 | Negative balances | Invalid (`E09`): overdrafts are assets and out of scope |
| 4 | Outlier threshold for `W04` | Factor 10 month on month |
| 5 | Data fingerprint | SHA-256 implemented in VBA, tested against published test vectors |

---

**Data principle:** keep the input as it was given, reject what breaks the
contract, flag what looks odd, and record exactly what each result was built
from.
