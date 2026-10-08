<div align="center">

# 📦 Installation and Developer Setup

### Set up, validate, and later import the IRRBB Toolkit into Excel

[![Status](https://img.shields.io/badge/Status-Foundation_only-6e7781?style=flat-square)](#current-status)
[![Checks](https://img.shields.io/badge/Checks-python_tools%2Fcheck.py-0969da?style=flat-square)](#run-the-checks)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776ab?style=flat-square&logo=python&logoColor=white)](#prerequisites)
[![Security](https://img.shields.io/badge/Security-Private_policy-d73a49?style=flat-square)](SECURITY.md)

<br>

**One identifiable commit · Clean import · Compile · Validate · Preserve caller state**

</div>

---

This document is authoritative for **developer setup, import, upgrade, recovery
and removal**. Contribution workflow is owned by
[`CONTRIBUTING.md`](CONTRIBUTING.md), vulnerability handling by
[`SECURITY.md`](SECURITY.md), and publication by [`RELEASING.md`](RELEASING.md).

> [!IMPORTANT]
> VBA executes with the user's Office permissions. Review the exact source,
> follow organizational macro policy, and never enable macros in an untrusted
> workbook.

<a id="current-status"></a>

## 🧭 Current status

Milestone **v0.1.0 – Repository foundation** is in progress. There is **no
IRRBB release** and **nothing to import into Excel yet**: the repository holds
documentation, issue governance, CI and static source checks only.

| Topic | Status |
| --- | --- |
| VBA source layout | Defined in [`docs/REPOSITORY_STRUCTURE.md`](docs/REPOSITORY_STRUCTURE.md) |
| VBA conventions | Defined in [`docs/VBA_HOUSE_STYLE.md`](docs/VBA_HOUSE_STYLE.md) |
| Static checks | Available: `python tools/check.py` |
| VBA source, workbook template | Not yet present |
| Regression harness | Not yet present |
| Excel evidence | Policy defined in [`docs/EXCEL_EVIDENCE.md`](docs/EXCEL_EVIDENCE.md) |
| Released versions | None |

Passing static checks is **not** evidence of correct IRRBB calculations.

<a id="prerequisites"></a>

## 🧰 Prerequisites

| Tool | Needed for |
| --- | --- |
| Git | Cloning and all repository work |
| Python 3.10 or later | `python tools/check.py`; standard library only, no packages |
| Node.js 20 or later | Optional: local label-catalogue checks |
| Microsoft Excel for Windows | **Future** VBA import, compile and model execution; not needed for static checks |

<a id="supported-hosts"></a>

## 🖥️ Intended hosts

| Host | Intended support level |
| --- | --- |
| Microsoft 365 or Excel 2016 and later, **Windows, 64-bit** | Target |
| Same versions, Windows, 32-bit | To be decided |
| Excel for Mac, Excel for the web | Not planned |

This table is a **design intent**, not a support commitment or a test result.
It is confirmed by an owner decision recorded in an issue before the first VBA
source is added, together with the list of permitted VBA references.

## 📥 Get the source

Use a **Git clone**:

```sh
git clone https://github.com/danielep71/VBA-IRRBB-Toolkit.git
cd VBA-IRRBB-Toolkit
git switch release/0.1.0
```

`release/0.1.0` is the active development branch; `main` receives it only on
the owner's request.

Do not use **Code → Download ZIP**. `.gitattributes` excludes repository
plumbing such as `.gitattributes`, `.gitignore`, `.editorconfig` and `.github/`
from GitHub archives, so a ZIP is not a complete checkout and the checks will
not behave as documented.

A clone checks VBA files out with the CRLF line endings the VBE expects. Do not
download individual modules through GitHub's **Raw** view: it serves the LF
form stored in Git.

<a id="run-the-checks"></a>

## ✅ Run the checks

From the repository root:

```sh
python tools/check.py
```

All gates must pass. Before pushing a committed candidate, the stricter form
also requires a clean working tree:

```sh
python tools/check.py --ci
python tools/check.py --ci --base <base-sha>   # for a pull request's full range
```

Optional label-catalogue checks:

```sh
node .github/scripts/labels-sync.mjs --policy .github/label-policy.json --self-test
node .github/scripts/labels-drift.mjs --policy .github/label-policy.json --self-test
```

The gates are described in [`tools/README.md`](tools/README.md). They are static
checks: they never compile VBA, run Excel or validate a model.

<a id="importing-vba-into-excel"></a>

## 📂 Importing VBA into Excel

> [!NOTE]
> There is no VBA to import yet. This section fixes the contract that the first
> source change must follow; the exact component list is added with it.

1. Start from **one exact commit** in a Git checkout, so `.bas`, `.cls` and
   `.frm` files have CRLF line endings. Never mix components from different
   commits.
2. Build the workbook from the macro-free template (planned path
   `src/workbook/IRRBB_Template.xlsx`) and save it as a macro-enabled workbook
   **outside** the checkout or in an ignored location. Built workbooks are never
   committed.
3. Import in dependency order: `src/core/`, then `src/classes/`, then
   `src/modules/`, then the standard modules in `src/workbook/`, then
   `src/forms/` (each `.frm` with its `.frx`). For a development workbook only,
   add `tests/` and `examples/` modules.
4. Paste document-module code (`ThisWorkbook`, sheet modules) into the existing
   module instead of importing it, which would create a duplicate class.
5. Run **Debug → Compile VBAProject**; it must complete with no error.
6. Run the synthetic regression harness and the specific scenario under test,
   then record the result as described under
   [validation record](#validation-record).

Do not paste source into arbitrarily named modules: the component name
(`VB_Name`) is part of the contract, and `tools/check_source.py` requires it to
match the file name.

### Exporting changes back

1. In the VBE, export each changed component over its file in the checkout, in
   the same folder.
2. Review `git diff`. The VBE silently changes the capitalization of an
   identifier everywhere it appears when one declaration changes case; revert
   case-only changes you did not intend.
3. Run `python tools/check.py`.
4. Commit. Git stores the files with LF; you do not convert anything by hand.

<a id="validation-record"></a>

## 🧪 Validation record

A successful import is not certification. Record at least:

```text
Commit (full SHA):
Files imported:
Excel / Office version and build:
Office bitness:
Operating system:
Compile:
Regression harness:
Reference cases, tolerances and results:
Specific scenario:
Cleanup:
Skipped or unverified:
```

A skipped, incomplete or cleanup-failed run is not a pass. Static checks cannot
substitute for Excel execution. Commit-bound evidence follows
[`docs/EXCEL_EVIDENCE.md`](docs/EXCEL_EVIDENCE.md).

## ⬆️ Upgrade

Before moving to a newer commit:

1. read the changelog between the two commits;
2. back up the host workbook, parameter sets and any user configuration;
3. identify the complete component set at the target commit; and
4. review compatibility notes and known limitations.

Replace the whole component set, compile again and repeat the validation. Do not
infer backward compatibility from successful compilation alone. A change in
estimated parameters between commits must be explained by the changelog.

Treat a locally modified copy as a fork: diff it against the old and new source,
reapply modifications deliberately and retest them.

## 🧯 Troubleshooting

| Symptom | Check first |
| --- | --- |
| `tools/check.py` fails on a clean clone | Python 3.10+ is on `PATH`, and the checkout is a Git clone, not a ZIP. |
| `tools/check.py --ci` fails locally | The working tree is clean and every change is committed. |
| `tools/check.py` reports CRLF in Git | Renormalize with `git add --renormalize .` and commit the result separately. |
| Compile error or missing procedure | All components come from one commit, and required references are set. |
| Ambiguous name | Remove duplicate or older copies of a component. |
| Different result from a reference | Confirm the commit, inputs, data window, settings and the independent reference used. |
| Security warning | Verify the source origin and organizational macro settings. |

Suspected security problems follow [`SECURITY.md`](SECURITY.md), not issues.

## 🗑️ Removal

1. Run any project-owned shutdown or cleanup procedure.
2. Remove the components and integrations the project owns.
3. Compile the remaining VBA project.
4. Close and reopen, and verify nothing still depends on removed components.

Removing modules does not remove formulas, names, links, connections or other
host integrations. Remove only state the project owns.

## 📚 Related documents

- [`README.md`](README.md) — overview and status
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — change and review workflow
- [`tools/README.md`](tools/README.md) — static checks and CI
- [`RELEASING.md`](RELEASING.md) — release sequence
- [`SECURITY.md`](SECURITY.md) — vulnerability and data-handling policy

---

**Installation principle:** use one identifiable commit, compile it, exercise
its real behavior in Excel, and record what was and was not validated.
