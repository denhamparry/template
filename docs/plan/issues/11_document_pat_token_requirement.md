# GitHub Issue #11: Document PAT_TOKEN requirement for pre-commit autoupdate

**Issue:** [#11](https://github.com/denhamparry/template/issues/11)
**Status:** Implementation Complete
**Date:** 2026-07-08

## Problem Statement

PR #10 changed `.github/workflows/pre-commit-autoupdate.yml` so hook updates are
published with `secrets.PAT_TOKEN`. The workflow now fails clearly when hook
updates are found and `PAT_TOKEN` is not configured, but the template setup
documentation does not tell downstream repositories to provision that secret.

Fresh repositories created from this template can therefore inherit a recurring
weekly workflow failure without setup guidance explaining the required secret,
capabilities, or reason the default `GITHUB_TOKEN` is not used.

## Acceptance Criteria

- `docs/setup.md` documents the `PAT_TOKEN` requirement for the pre-commit
  autoupdate workflow.
- The setup docs describe the required token capabilities:
  `contents: write` and `pull-requests: write`.
- The setup docs explain why the default `GITHUB_TOKEN` is insufficient for
  this workflow.
- `CLAUDE.md` customization checklist includes provisioning `PAT_TOKEN` or
  deleting the workflow if autoupdates are not wanted.
- The hard-fail versus graceful-degrade decision is recorded.

## Current State Analysis

- Issue #11 is open and labeled `documentation` and `github_actions`.
- `.github/workflows/pre-commit-autoupdate.yml` already documents its token
  strategy in comments and hard-fails when updates exist without `PAT_TOKEN`.
- `docs/setup.md` GitHub Integration currently documents only
  `CLAUDE_CODE_OAUTH_TOKEN`.
- `CLAUDE.md` customization checklist mentions replacing the autoupdate
  assignee but not provisioning `PAT_TOKEN`.

## Implementation Plan

1. Update `docs/setup.md` GitHub Integration with a checklist item and concise
   explanation for the pre-commit autoupdate `PAT_TOKEN` secret.
2. Document acceptable token forms as a fine-grained PAT or GitHub App
   installation token with `contents: write` and `pull-requests: write`.
3. Explain that the workflow intentionally does not rely on `GITHUB_TOKEN`
   because repository or organization settings can block PR creation and PRs
   opened with the default token do not trigger the required `pre-commit`
   status check.
4. Record the decision to keep the workflow's hard failure for missing
   `PAT_TOKEN` so misconfigured template-derived repositories get an actionable
   setup error instead of silently skipping hook updates.
5. Update `CLAUDE.md` customization checklist with the required setup item.
6. Run documentation validation and update this plan with outcomes.

## Files Expected To Change

- `docs/setup.md`
- `CLAUDE.md`
- `docs/plan/issues/11_document_pat_token_requirement.md`

## Validation Plan

- `git diff --check`
- `pre-commit run --all-files`
- Manual review to confirm:
  - both issue-requested docs surfaces mention `PAT_TOKEN`;
  - scopes are listed exactly as `contents: write` and `pull-requests: write`;
  - the `GITHUB_TOKEN` limitation is explained without over-specifying token
    creation steps;
  - the hard-fail decision is recorded.

## Risks And Open Questions

- The docs should not imply Codex or Claude can create or store the token for
  the user. A repository operator must provision the secret.
- GitHub UI labels for fine-grained token permissions may change, so the docs
  should stay concise and capability-oriented.

## Research Validation

- Iteration 1, 2026-07-08: Approved. The plan satisfies issue #11, keeps scope
  to documentation and this plan note, avoids changing the already-implemented
  workflow behavior, and includes validation specific to the requested docs.

## Outcome

Implemented the documentation update. `docs/setup.md` now tells template users
to provision a `PAT_TOKEN` repository secret for the pre-commit autoupdate
workflow, lists the required `contents: write` and `pull-requests: write`
capabilities, explains why `GITHUB_TOKEN` is insufficient, and records the
decision to keep the workflow's hard failure when hook updates are found but
the secret is missing.

`CLAUDE.md` now includes a customization checklist item to provision the
`PAT_TOKEN` secret or delete the autoupdate workflow if it is not wanted.

## Validation

- `git diff --check` - passed.
- `pre-commit run --all-files` - passed after staging the new plan file.
- Manual acceptance review - passed:
  - both requested docs surfaces mention `PAT_TOKEN`;
  - `docs/setup.md` lists `contents: write` and `pull-requests: write`;
  - `docs/setup.md` explains the `GITHUB_TOKEN` PR creation and CI-trigger
    limitations;
  - the hard-fail decision is recorded in `docs/setup.md` and this plan.

## Review

- Classified as non-code documentation changes: `CLAUDE.md`, `docs/setup.md`,
  and this issue plan. No source, executable workflow, dependency, lockfile, or
  CI implementation changed.
- No `docs/pre-pr-branch-review.md` guide exists in this repository.
- Trail of Bits review skills were skipped because there are no code-relevant
  changes.
- Manual review found no blocking issues. The docs avoid storing or implying
  creation of token values and keep the setup guidance concise.
- No follow-up enhancement issues were created; default workflow mode keeps
  non-blocking ideas in the PR body.
