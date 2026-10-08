# Release and integration policy

Development uses `release/0.1.0`; owner-approved integration into `main` is separate from creating a GitHub Release.

- Milestones organize work but do not imply a tag or publication.
- No `VERSION`, tag or Release is created before explicit approval.
- Freeze candidate SHA; require green static checks, documented VBA compile and synthetic numerical evidence for implemented calculations.
- Integrate by a reviewed PR; keep release branch aligned according to an owner-approved plan.
- Publish only artifacts built from and tested against the exact certified source.
- Update `CHANGELOG.md` from `Unreleased` only when the release is prepared.
