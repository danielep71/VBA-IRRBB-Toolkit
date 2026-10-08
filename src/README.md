# Production VBA source

Source-first application profile, adapted from VBA-SACCR-Toolkit.

- `core/`: host-independent numerical, econometric and validation functions (`CORE_*`, `Option Private Module`). `tools/check_source.py` rejects Excel object-model and UI identifiers here.
- `modules/`: explicitly supported public facade (`IRRBB_*`).
- `workbook/`: host adapters and exported Excel document modules.
- `classes/`, `forms/`: introduce only when needed.

No production VBA is shipped in the repository foundation milestone. Layout, dependency direction and the parameter and units boundary are defined in [`docs/REPOSITORY_STRUCTURE.md`](../docs/REPOSITORY_STRUCTURE.md).
