# Contributing

## Change workflow

1. Work from `release/0.1.0` using a focused task branch, not directly on main.
2. Create/associate an issue with testable acceptance criteria and an exact priority.
3. Preserve source-first boundaries: internal core, public facade, workbook adapters.
4. Use synthetic data. Do not commit customer material, vendor-proprietary files or credentials.
5. Update documentation and `CHANGELOG.md` for user-visible changes.
6. Run `python tools/check.py`; report the exact commit, checks and genuine Excel evidence separately.
7. Open a PR against `release/0.1.0` using the template. Merge only after review and passing gates.

Changes to statistical estimators require independent numerical reference cases, tolerances, documented failure behavior, convergence and reproducibility. Backtesting must never reuse future information.
