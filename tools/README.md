# Repository tooling

The tools are adapted from the shared source-first conventions and portable source gates of VBA-SACCR-Toolkit; they do not perform IRRBB calculations.

```shell
python tools/check.py
python tools/check.py --ci
python tools/check.py --ci --base <base-sha>
```

The gate runner checks:
- Python-tool regression self-tests;
- committed / working-tree whitespace;
- source placement, LF storage and VBA export headers;
- VBA jump targets and conditional compilation across supported Windows bitness contexts;
- explicit public API declarations compared with `docs/PUBLIC_API.txt`;
- changelog/version consistency.

CI runs these checks on GitHub's hosted Linux runner. **VBA compile, Excel workbook execution, econometric calibration and numerical result validation are not performed by these gates.** Record Excel host evidence separately under `docs/EXCEL_EVIDENCE.md`.

Label reconciliation scripts and workflows mirror the SACCR label policy; merging them into the trusted default branch is needed before automatic label synchronization begins.
