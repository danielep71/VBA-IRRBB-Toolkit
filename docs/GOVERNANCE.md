# Governance

## Workflow

- Active integration branch: `release/v0.1.0`.
- Start focused task branches from the release branch; open PRs back into it.
- No direct commits to `release/v0.1.0` or `main` after the initial repository bootstrap.
- A release-to-main PR requires the owner's explicit approval. No version tags or releases are implied.
- Merge only with reviewer sign-off and green repository checks; Excel evidence is separately recorded when VBA changes exist.

## Issue metadata

- One owner: `danielep71` for each new issue, unless explicitly reassigned.
- Exactly one priority: `P1` (blocking correctness/security), `P2` (significant), `P3` (non-blocking).
- Add suitable type labels, a milestone and verifiable checkboxes; titles do not carry version prefixes.
- Issues may be closed only when their acceptance criteria are evidenced; links to code and tests should be recorded.

## Privacy and intellectual property

Use only synthetic examples and independent work. The repository's private status is not authorization to store client files, personal data or confidential vendor methods. Third-party licensing and method provenance must be resolved before implementation.

## Definition of done

A change is complete only when (1) the issue contract is satisfied; (2) tests, diagnostics and failure behavior are addressed; (3) docs and changelog are current; (4) `python tools/check.py --ci` passes on the exact source commit; and (5) genuine Excel compilation, execution and independent result evidence is attached when relevant.

Static CI does not compile or execute VBA.
