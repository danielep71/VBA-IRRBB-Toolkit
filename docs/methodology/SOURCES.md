<div align="center">

# 📚 Source Register

### Every external source the model contracts rely on, and whether it has been checked

[![Status](https://img.shields.io/badge/Verified-none_yet-d97706?style=flat-square)](#register)
[![Rule](https://img.shields.io/badge/Rule-cite%2C_never_copy-6f42c1?style=flat-square)](../../CONTRIBUTING.md#data-confidentiality-and-provenance)

</div>

---

This register is authoritative for **which external sources the toolkit relies
on and whether each has been verified against its official text**. Model
contracts in [`MODEL_CONTRACTS.md`](MODEL_CONTRACTS.md) cite sources by ID.
Sources are cited by reference only; their text is never copied into the
repository.

> [!WARNING]
> No entry has been verified yet. Figures attributed to a source below are
> recalled, not checked. A regulatory rule may be implemented only after its
> entry is marked verified, with the exact provision and version recorded, by a
> reviewed change.

<a id="register"></a>

## Register

### Regulatory and supervisory

| ID | Source | Relied on for | Verified |
| --- | --- | --- | :---: |
| `REG-1` | Basel Committee on Banking Supervision, *Interest rate risk in the banking book*, standards, April 2016 | Non-maturity deposit categories (retail transactional, retail non-transactional, wholesale); the standardised framework's caps on the core proportion and average maturity of core deposits per category | ☐ |
| `REG-2` | European Banking Authority, *Guidelines on IRRBB and CSRBB*, EBA/GL/2022/14 | Expectations on behavioral assumptions for non-maturity deposits, their documentation and validation | ☐ |
| `REG-3` | Commission Delegated Regulation (EU) on regulatory technical standards for the supervisory outlier test (supervisory shock scenarios and common modelling assumptions), adopted in 2024 | Supervisory shock scenarios, the post-shock interest-rate floor, and the cap on the average repricing maturity of non-maturity deposits used in the outlier test | ☐ |

The exact regulation number, article and paragraph for `REG-3` are recorded
when the entry is verified.

### Econometric and statistical

| ID | Source | Relied on for | Verified |
| --- | --- | --- | :---: |
| `ECO-1` | Engle, R. F. and Granger, C. W. J. (1987), "Co-integration and error correction: representation, estimation, and testing", *Econometrica* 55(2), 251–276 | Two-step estimation of the long-run relation and the error-correction model | ☐ |
| `ECO-2` | Dickey, D. A. and Fuller, W. A. (1979), "Distribution of the estimators for autoregressive time series with a unit root", *Journal of the American Statistical Association* 74, 427–431 | Unit-root tests on the rate series | ☐ |
| `ECO-3` | MacKinnon, J. G. (2010), "Critical values for cointegration tests", Queen's Economics Department Working Paper 1227 | Critical values for the residual-based cointegration test | ☐ |
| `ECO-4` | Newey, W. K. and West, K. D. (1987), "A simple, positive semi-definite, heteroskedasticity and autocorrelation consistent covariance matrix", *Econometrica* 55(3), 703–708 | Standard errors robust to autocorrelation | ☐ |
| `ECO-5` | Papke, L. E. and Wooldridge, J. M. (1996), "Econometric methods for fractional response variables with an application to 401(k) plan participation rates", *Journal of Applied Econometrics* 11(6), 619–632 | Fractional-response logit for monthly survival shares | ☐ |

## Verifying an entry

1. Obtain the official text from its publisher.
2. Record the exact title, version or publication date, and the article,
   paragraph or table relied on.
3. Check every figure or rule the contracts attribute to it.
4. Mark the entry verified in a reviewed change that names the reviewer, and
   correct the contracts where they differ.

A source that cannot be obtained stays unverified, and anything resting on it
stays a proposal.
