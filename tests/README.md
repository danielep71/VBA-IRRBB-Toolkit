# Tests

Future Excel regression harness `TEST_Harness.RunTests`, synthetic fixtures and reviewed expected values belong here. Group cases by model (Rates, Stable, Decay), transformation, validation and application recovery. Distinguish static checks from execution in real Excel.

Synthetic fixtures for the data contract are in `fixtures/data_contract/`, with hand-computed expectations in `expected/data_contract/`; `tools/test_data_contract.py` keeps them consistent with [`docs/methodology/DATA_CONTRACT.md`](../docs/methodology/DATA_CONTRACT.md).

No numerical test passes are claimed for v0.1.0. Do not commit actual customer records or proprietary benchmarks.
