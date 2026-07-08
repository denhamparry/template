# GitHub Issue #9: Fix pre-commit autoupdate PR creation token

**Issue:** [#9](https://github.com/denhamparry/template/issues/9)
**Status:** Implementation Complete - Awaiting Secret Verification
**Date:** 2026-07-08

## Problem Statement

The scheduled `Pre-commit autoupdate` workflow successfully runs
`pre-commit autoupdate`, validates updated hooks, and pushes
`chore/pre-commit-autoupdate`, but the final `Create pull request` step fails
with:

```text
GitHub Actions is not permitted to create or approve pull requests.
```

The issue identifies the root cause as a repository or organization workflow
permission toggle that prevents PR creation with the default `GITHUB_TOKEN`.
The chosen fix is to mirror the verified `denhamparry/maintenance` PR #57
approach: use a provisioned `PAT_TOKEN` secret for
`peter-evans/create-pull-request`.

## Acceptance Criteria

- A `PAT_TOKEN` repository secret exists with `contents: write` and
  `pull-requests: write` capability.
- `.github/workflows/pre-commit-autoupdate.yml` passes
  `token: ${{ secrets.PAT_TOKEN }}` to the `Create pull request` step while
  retaining the pinned action SHA.
- The workflow header and generated PR body no longer describe the
  close/reopen workaround for `GITHUB_TOKEN` PRs.
- A manual `workflow_dispatch` run completes end to end by opening/updating a
  pre-commit autoupdate PR, or cleanly no-ops when there are no hook updates.
- The existing remote `chore/pre-commit-autoupdate` branch is reconciled by the
  successful workflow run or deleted before the next run recreates it.
- Local validation passes:
  - `git diff --check`
  - `pre-commit run --all-files`

## Current State Analysis

- Issue #9 is open and labeled `bug` and `github_actions`.
- The template workflow still documents two token options and the generated PR
  body still tells maintainers to close and reopen the PR to trigger CI.
- `gh secret list --repo denhamparry/template` does not currently list any
  repository secrets as of 2026-07-08, so `PAT_TOKEN` is not visibly
  provisioned.
- The remote `chore/pre-commit-autoupdate` branch exists and is tracked by the
  repository.
- Reference fix `denhamparry/maintenance` PR #57 is merged as of 2026-07-08.

## Implementation Plan

1. Update `.github/workflows/pre-commit-autoupdate.yml` to fail clearly when
   hook updates are found but `PAT_TOKEN` is not configured.
2. Pass `secrets.PAT_TOKEN` into the pinned
   `peter-evans/create-pull-request` action.
3. Trim the workflow header to document the token-based final approach and the
   secret requirement.
4. Remove the generated PR body's obsolete close/reopen caveat because PRs
   created by the provisioned token should trigger `pre-commit` automatically.
5. Record the remaining operational requirement to provision `PAT_TOKEN` and
   reconcile the existing autoupdate branch before considering issue #9 fully
   verified.
6. Run local validation and update this plan with the outcome.

## Files Expected To Change

- `.github/workflows/pre-commit-autoupdate.yml`
- `docs/plan/issues/9_pre_commit_autoupdate_pr_token.md`

## Validation Plan

- `git diff --check`
- `pre-commit run --all-files`
- Manual review of the workflow diff to confirm:
  - the `peter-evans/create-pull-request` SHA pin is unchanged;
  - the workflow fails with a clear message if updates exist but `PAT_TOKEN` is
    missing;
  - the new token input only references the secret and does not expose a token;
  - the generated PR body no longer instructs close/reopen CI workarounds.
- GitHub-side verification after an operator provisions `PAT_TOKEN`:
  - run `Pre-commit autoupdate` with `workflow_dispatch`;
  - confirm it opens or updates a PR, or no-ops cleanly when no hook updates
    exist;
  - confirm the resulting PR triggers the `pre-commit` check.

## Risks And Open Questions

- `PAT_TOKEN` is not currently provisioned, and this work cannot safely invent
  or store a token value. A repository operator must add a fine-grained PAT or
  GitHub App installation token with the required capabilities.
- If the existing `chore/pre-commit-autoupdate` branch conflicts with the next
  workflow attempt, delete that branch after preserving any desired hook update
  diff, then rerun the workflow.
- Because the changed file is a GitHub Actions workflow, branch review should
  treat this as code-relevant even though the repository is documentation-heavy.

## Research Validation

- Iteration 1, 2026-07-08: Approved. The plan matches issue #9, mirrors the
  merged `denhamparry/maintenance` PR #57 repository-side fix, keeps scope
  limited to the autoupdate workflow plus this plan, and correctly records
  that full end-to-end acceptance still requires an operator to provision
  `PAT_TOKEN` and run the workflow.

## Outcome

Implemented the repository-side workflow change. The `Pre-commit autoupdate`
workflow now requires `PAT_TOKEN` when hook updates are found, passes that
secret to the pinned `peter-evans/create-pull-request` action, and no longer
generates PR text that tells maintainers to close and reopen the PR to trigger
CI.

Full end-to-end verification is still blocked until a repository operator
provisions `PAT_TOKEN` with `contents: write` and `pull-requests: write`.
After that secret exists, run the workflow with `workflow_dispatch` and confirm
it opens or updates the autoupdate PR, or no-ops cleanly if there are no hook
updates.

## Validation

- `git diff --check` - passed.
- `pre-commit run --all-files` - passed.
- `gh secret list --repo denhamparry/template` - returned no visible
  repository secrets on 2026-07-08.
- `gh pr list --repo denhamparry/template --head chore/pre-commit-autoupdate --state all --json number,state,title,url,headRefName,updatedAt` -
  returned no PRs on 2026-07-08.
- `git diff --name-status origin/main..origin/chore/pre-commit-autoupdate` -
  confirmed the existing remote autoupdate branch only changes
  `.pre-commit-config.yaml`.

## Review

- Classified as code-relevant because `.github/workflows/pre-commit-autoupdate.yml`
  changes a GitHub Actions workflow.
- No `docs/pre-pr-branch-review.md` guide exists in this repository.
- Trail of Bits `differential-review` and specialist review skills were not
  available in this Codex session, so a manual branch-diff review was
  performed.
- Manual review found no blocking issues. The workflow fails clearly if updates
  exist and `PAT_TOKEN` is missing, references only the repository secret,
  keeps the `peter-evans/create-pull-request` SHA pin unchanged, and removes
  the obsolete close/reopen CI workaround from generated PR text.
- `actionlint` is not installed locally; workflow syntax was covered by the
  repository pre-commit YAML check.
- No follow-up enhancement issues were created; default workflow mode keeps
  non-blocking operational notes in the PR body.
