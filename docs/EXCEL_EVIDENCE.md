# Real Excel evidence policy

Portable checks (`python tools/check.py`) cannot compile or run VBA.

When VBA or workbook features are introduced, record:

1. Exact Git commit SHA and workbook build source.
2. Excel version, bitness, operating system and macro security context.
3. Clean import and `Debug → Compile VBAProject` outcome.
4. Test entry point, synthetic dataset, expected reference, actual output, tolerance and pass/fail result.
5. Evidence of failure handling: invalid inputs, recovery after interrupted runs, and stale-result withdrawal.

Evidence must be tied to the exact source SHA. Changes after certification invalidate earlier evidence for affected calculations. Do not commit sensitive screenshots, client data or proprietary workbook content.
