# Development workbook build

Assembles a macro-enabled **development** workbook from one checked-out commit, so the decay engine and the regression harness can be compiled and run in Excel and recorded per [`docs/EXCEL_EVIDENCE.md`](../../docs/EXCEL_EVIDENCE.md). It is not the workbook template of #5, not the import/export helper of #6, and never the production deliverable.

| Script | Purpose |
| --- | --- |
| `build_dev_workbook.py` | Writes `build/IRRBB_Dev.xlsm` (ignored by Git): sheets `Readme` (commit SHA, build time, components), `Checks` (harness output) and `DecayExample`; embeds every `.bas` in `src/core`, `src/modules`, `src/workbook`, `tests/modules` and `examples/modules` unchanged, with document modules for `ThisWorkbook` and each sheet. Requires `openpyxl`. A dirty working tree is stamped as not evidence-grade. |
| `vba_project.py` | Writes `vbaProject.bin` from the [MS-OVBA] and [MS-CFB] specifications: compressed module source, `dir` stream, `PROJECT` streams, no p-code cache, so Excel compiles from source on open. Deterministic for a given commit. |
| `lo_smoke.py` | Optional early warning: opens the workbook in headless LibreOffice with VBA compatibility, runs the harness and the example, forces one invalid input and prints a JSON summary. LibreOffice is not a supported host; this is never Excel evidence. Needs LibreOffice and `python3-uno`. |

```shell
pip install openpyxl
python tools/devbuild/build_dev_workbook.py
python tools/devbuild/lo_smoke.py            # optional
```

If Excel rejects or strips the embedded project, fall back to the manual import order in [`INSTALLATION.md`](../../INSTALLATION.md#importing-vba-into-excel) on a workbook with sheets named `Readme`, `Checks` and `DecayExample`, and report the failure in an issue.
