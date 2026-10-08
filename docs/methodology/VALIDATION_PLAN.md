# Validation and backtesting plan

## Separation of responsibilities

Calibration, independent challenge and acceptance must be distinguishable. Code review and green CI are necessary but not evidence of econometric correctness.

## Model validation matrix

| Model | Minimum independent checks |
| --- | --- |
| Rates | OLS reference examples, constrained-parameter tests, residual behavior, ECM formulation, time alignment, scenarios and forecast errors |
| Stable | Synthetic cash-out identity, probability bounds, logit fit against a separately computed benchmark, missing-account treatment and predictor selection trace |
| Decay | Log-change identities, volatility and quantiles, mean-life numerical check, profile monotonicity, schedule sum and profile coverage |
| Common | Segment reconciliation, leakage checks, extreme values, failures with clean output withdrawal, repeatability and unit conventions |

## Out-of-sample backtesting

The estimation and test windows, forecast origins, horizons and scores are specified in [`MODEL_CONTRACTS.md`](MODEL_CONTRACTS.md#estimation-window-and-out-of-sample-freeze).

Freeze the original model coefficients before the test period. Reconstruct forecasts using only information known at each forecast date. Report MAE/RMSE/bias or other justified diagnostics, confidence-band exceedances and stability. For decay, compare remaining balances to the hypothesized runoff profile with clearly defined cohorts and horizons. A recalibration is a separate, later experiment.

## Evidence protocol

Each test must identify source SHA, fixture name, expected result provenance, numerical tolerance, actual outcome, Excel host details and reviewer. Cases, their provenance rules and tolerances are registered in [`TEST_CASES.md`](TEST_CASES.md). Retain synthetic examples only in Git. Never claim a passed Excel test on the basis of a Python static gate.

## Open design decisions

- Exact data schema and strategy for datasets larger than worksheet limits. Decided in issue #4 ([`DATA_CONTRACT.md`](DATA_CONTRACT.md)).
- Choice of independent numerical benchmark. Decided in issue #3: Python or R may produce reference values **outside** the workbook; they are never runtime dependencies ([`INSTALLATION.md`](../../INSTALLATION.md#runtime-dependencies)).
- Treatment of curve scenarios, behavioral caps and regulatory constraints. Proposed in issue #9 ([`MODEL_CONTRACTS.md`](MODEL_CONTRACTS.md#regulatory-overlay)); depends on verifying the sources in [`SOURCES.md`](SOURCES.md).
- Downstream ALM platform integration schema, ownership and reconciliation requirements.
