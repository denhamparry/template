---
status: In Progress
---

# GitHub Issue #38: Migrate pre-commit autoupdate from PAT_TOKEN to a GitHub App token

**Issue:** [#38](https://github.com/denhamparry/template/issues/38)
**Status:** In Progress (repository change complete; live verification pending)
**Date:** 2026-10-09

## Problem Statement

The weekly autoupdate workflow authenticates its pull requests with the
long-lived `PAT_TOKEN` secret, the only Actions secret in this repository
(observed 2026-10-09). The PAT may be shared with other repositories, so it can
only be revoked after every consumer has moved to GitHub App tokens. Fleet
tracking: denhamparry/maintenance#126. The maintenance copy of this workflow
gained App-first credential selection in denhamparry/maintenance#147 and its
token-scope fix in denhamparry/maintenance#149 (closing
denhamparry/maintenance#148), which unblocks this port.

## Changes

- [x] `.github/workflows/pre-commit-autoupdate.yml`: ported from maintenance at
      `00704d8`, keeping `runs-on: ubuntu-latest` (the only prior difference).
      - App-first credential selection: App when both `APP_CLIENT_ID` (variable)
        and `APP_PRIVATE_KEY` (secret) are set; `PAT_TOKEN` only when neither
        is set; a partial App configuration or no credential fails.
      - Repository name derived from `GITHUB_REPOSITORY` and validated before
        minting, not taken from the event payload.
      - Pinned `actions/create-github-app-token@bcd2ba4…` (v3.2.0), contents
        and pull-requests write, empty-token assertion, and token selection for
        `create-pull-request`.
      - Header comment and PAT warning are generic, because derived
        repositories copy this file.
- [x] `docs/setup.md` and the `CLAUDE.md` checklist describe the App
      credentials first and `PAT_TOKEN` as the legacy fallback.
- [ ] Owner: install the App and set `APP_CLIENT_ID` and `APP_PRIVATE_KEY`
      together.
- [ ] Owner: record a scheduled run in which the mint and create-pull-request
      steps executed.
- [ ] Follow-up PR: remove the PAT fallback; then delete `PAT_TOKEN`. Revoke the
      PAT only after the fleet consumer audit in denhamparry/maintenance#126.

While no App credential is configured, the merged workflow keeps using
`PAT_TOKEN`, so merging before provisioning causes no behaviour change.

## Validation

- `diff` against maintenance `00704d8`: only `runs-on`, the header comment and
  the PAT warning text differ.
- Credential-selection and repository-derivation `run:` bodies: `shellcheck`
  clean and fixture-tested with fake values.
- `actionlint` over all workflows.
- `pre-commit run --all-files`.
