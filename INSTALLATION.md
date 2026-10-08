# Installation and development

## Prerequisites

- Git
- Python 3.10+ (standard library; no additional packages needed by the initial checker)
- Windows 64-bit Excel for **future** VBA import and model execution; not needed for static source checks

## Checkout

```shell
git clone https://github.com/danielep71/VBA-IRRBB-Toolkit.git
cd VBA-IRRBB-Toolkit
git switch release/0.1.0
python tools/check.py
```

`python tools/check.py --ci` additionally checks the committed state and a clean working tree. `--base <base-sha>` analyzes a PR's complete committed range.

## Current limitations

The foundation contains no application workbook, module import script or statistical engine. Until the corresponding issues are completed, there is nothing to import or certify in Excel. Do not treat successful CI as evidence of correct IRRBB calculations.

## Future workbook import contract

Build from one exact Git commit; import checked-out exported source with compatible line endings; compile in Excel; run the workbook's synthetic regression harness; record Excel host and numerical evidence under `docs/EXCEL_EVIDENCE.md`.
