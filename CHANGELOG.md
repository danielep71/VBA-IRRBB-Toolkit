<div align="center">

# 📜 Changelog

### Release history for the IRRBB behavioral-model toolkit in Excel/VBA

[![Format](https://img.shields.io/badge/Format-Keep_a_Changelog-0969da?style=flat-square)](https://keepachangelog.com/en/1.1.0/)
[![Versioning](https://img.shields.io/badge/Versioning-SemVer-6f42c1?style=flat-square)](https://semver.org/spec/v2.0.0.html)
[![Dates](https://img.shields.io/badge/Dates-YYYY--MM--DD-217346?style=flat-square)](#date-and-version-rules)
[![Staging](https://img.shields.io/badge/Staging-Unreleased_first-d97706?style=flat-square)](#unreleased)
[![Contributing](https://img.shields.io/badge/Changes-Contribution_guide-2ea44f?style=flat-square)](CONTRIBUTING.md)

<br>

**User-visible history · Explicit compatibility · Reproducible evidence · Immutable releases**

</div>

---

All notable changes to the **IRRBB Toolkit** are documented here.

This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html). It records
released behavior and material unreleased changes; it is not a commit log, issue
tracker, or substitute for release evidence.

---

## 🧭 Maintenance policy

- Add material changes under **Unreleased** in the same pull request as the
  behavior or documentation they describe.
- Write from the user's perspective: describe the observable result, contract,
  compatibility impact, and migration need.
- Link the owning issue or pull request when it contains useful engineering
  detail.
- Record only validation actually performed. Static checks are never Excel
  evidence; state what was and was not run in Excel.
- Record any change to estimated parameters, stable shares, decay profiles or
  backtest statistics for unchanged inputs, with its cause.
- Move Unreleased entries into a dated version section only when a release is
  explicitly prepared.
- Do not edit a published release entry except to correct a demonstrable factual
  or link error; annotate material corrections instead of rewriting history.

See [CONTRIBUTING.md](CONTRIBUTING.md) for change and evidence requirements and
[SECURITY.md](SECURITY.md) for private vulnerability reporting.

<a id="date-and-version-rules"></a>

### Date and version rules

| Rule | Standard |
|---|---|
| Version | `MAJOR.MINOR.PATCH`, without the leading `v` in headings |
| Release heading | `## [X.Y.Z] - YYYY-MM-DD` |
| Date | Gregorian calendar date in ISO `YYYY-MM-DD` format |
| Ordering | Unreleased first; released versions newest to oldest |
| Comparison | Unreleased → latest tag; each release → preceding tag |
| Patch | Backward-compatible correction or hardening |
| Minor | Backward-compatible capability |
| Major | Incompatible public-contract change |

The repository remains below `1.0.0` while its supported surface is still
forming. Pre-release status does not excuse undocumented breaking changes.
`python tools/check.py` enforces these rules and the match with `VERSION`.

<details>
<summary><strong>Entry categories</strong></summary>

<br>

| Category | Use for |
|---|---|
| **Added** | New supported capabilities, APIs, files, or tests |
| **Changed** | Changes to existing behavior, contracts, tooling, or documentation |
| **Deprecated** | Supported behavior scheduled for removal |
| **Removed** | Removed capabilities or compatibility |
| **Fixed** | Corrected defects |
| **Security** | Safely disclosed security corrections |
| **Documentation** | Material documentation-only changes |
| **Validation** | Evidence actually produced |
| **Compatibility** | Upgrade or migration effects |
| **Known limitations** | Deliberate, unresolved boundaries |

Use only the categories needed by a release.

</details>

---

<a id="unreleased"></a>

## [Unreleased]

> Not yet released. Development takes place on the active release branch,
> `release/v0.1.0`; changes to `main` require an explicit owner instruction.

### Added

- Daily repository traffic export with private history, main-only analytics
  access, and traffic alerts, following the SA-CCR repository setup.
  Setup and verification are documented in `docs/TRAFFIC.md`.

- Initial repository foundation for a source-first Excel/VBA IRRBB behavioral
  modelling application.
- Documentation of model scope, validation requirements, source boundaries and
  synthetic-data policy.
- Portable static-checking tools and CI configuration adapted from the
  maintainer's SA-CCR repository.

### Changed

- The active release branch is now `release/v0.1.0`, opened from `main` after
  the foundation was integrated (PR #13). Documentation, the PR template and
  the `Bootstrap v0.1.0 tracking` workflow trigger point to it, and release
  branches are named `release/vX.Y.Z` from now on.

### Removed

- The one-off `Bootstrap v0.1.0 tracking` workflow and
  `tools/bootstrap_tracking.py`. The v0.1.0 milestone and issue metadata they
  created remain; the workflow no longer runs with `issues: write` on every
  push to the release branch.

### Documentation

- Root documents (`CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`,
  `INSTALLATION.md`, `RELEASING.md`, `SECURITY.md`) expanded to the
  maintainer's documentation standard, with headers, badges and complete
  workflow, evidence, security and release sections.

### Fixed

- Label commands now default to the checked-in `.github/label-policy.json`.
- Workbook package checks reject missing core parts and archive corruption;
  these structural checks do not certify Excel compatibility.
- Traffic history labels the repository count `open_issues_and_prs`, including
  pull requests, and preserves values when migrating the old CSV column.

### Known limitations

- No VBA source, workbook, regression harness or model engine exists yet.
- No automated check compiles VBA, runs Excel or validates a model; passing CI
  is not evidence of correct IRRBB calculations.
- The methodology is a roadmap, not a validated specification, and its
  regulatory reference register is not yet populated.

---

[Unreleased]: https://github.com/danielep71/VBA-IRRBB-Toolkit/compare/main...release/v0.1.0
