# Repository structure and application profile

This file defines the source layout and architectural boundaries, following the source-first **application** profile used by VBA-SACCR-Toolkit.

## Profile decision

The intended deliverable is an Excel workbook with a user-facing workflow for importing synthetic/model-permitted datasets, calibrating and applying models, running backtests and exporting ALM parameters. It is **not** a standalone VBA add-in or a library-only project. The calculation core must remain independent of Excel.

```text
.github/               Issue forms, labels, CI and repository automation
docs/                  Architecture, methods, public API, evidence and governance
docs/methodology/      Model specifications, source register and validation contract
examples/              Synthetic, reproducible examples
src/core/              Internal VBA numerical and statistical engines
src/modules/           Public VBA facade (IRRBB_*), reviewed API
src/workbook/          Excel adapters, document modules, future .xlsx template
src/classes/           Internal class modules when needed
src/forms/             UserForms when needed
tests/                 Excel VBA harness and reviewed synthetic fixtures
tools/                 Cross-platform quality gates; no calculation engine
```

Directories without implementation content are created only when the first real source file is added. Top-level README files describe planned responsibilities.

## Dependencies

```text
Excel sheets / ribbon / workbook events
                |
          src/workbook/
                |
          src/modules/  (public facade)
                |
          src/core/     (pure VBA models and math)
```

- `src/core/` has no `Worksheet`, `Range`, `Workbook`, dialogs or UI state; standard modules declare `Option Private Module`.
- `src/modules/` owns supported entry points named `IRRBB_*`, and they are inventoried in `docs/PUBLIC_API.txt`.
- `src/workbook/` is an adapter; it does not silently transform regulatory or statistical assumptions.
- Units, rate conventions, temporal alignment, model version and segment identifiers are explicit at API boundaries.
- Parameter export formats, including ERMAS, are adapters, not business logic, and will be implemented only after a contract is agreed.
- Every change to a model requires independently sourced expected values and numerical tolerances; the model must not validate itself.

## Version control

Exported `.bas`, `.cls` and `.frm` modules are authoritative. Generated macro-enabled workbooks and unapproved binary files must not be committed. A future sanitized macro-free `.xlsx` template may be versioned as an explicit exception after inspection.

Development branch: `release/0.1.0`; `main` is updated only by an owner-approved integration. A release is not implied by creating a milestone.
