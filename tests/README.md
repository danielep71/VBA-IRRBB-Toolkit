# Tests

The Excel regression harness `TEST_Harness.RunTests` (`modules/`), synthetic fixtures and reviewed expected values belong here. Group cases by model (Rates, Stable, Decay), transformation, validation and application recovery. Distinguish static checks from execution in real Excel.

Synthetic fixtures for the data contract are in `fixtures/data_contract/`, with hand-computed expectations in `expected/data_contract/`; `tools/test_data_contract.py` keeps them consistent with [`docs/methodology/DATA_CONTRACT.md`](../docs/methodology/DATA_CONTRACT.md).

Decay cases: fixtures and their generator in `fixtures/decay/`; independent expected values (numpy, scipy) with provenance in `expected/decay/`, produced by `expected/decay/make_expected.py`, which also regenerates `modules/TEST_DecayData.bas` (`--emit-vba`; never edit it by hand). `modules/TEST_DecayCases.bas` implements the cases; `modules/TEST_Harness.bas` runs every registered case and lists the unbuilt ones as NOT RUN.

No numerical test passes in Excel are claimed for v0.1.0: the decay cases have only been run in LibreOffice as a proxy. Do not commit actual customer records or proprietary benchmarks.
