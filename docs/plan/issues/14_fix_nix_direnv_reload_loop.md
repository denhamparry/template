# GitHub Issue #14: fix(nix): direnv reloads dev shell on every prompt

**Issue:** [#14](https://github.com/denhamparry/template/issues/14)
**Status:** Complete
**Date:** 2026-07-08

## Problem Statement

The template's `.envrc` uses `use flake`, but `flake.lock` is gitignored and
untracked. With nix-direnv, both `flake.nix` and `flake.lock` are watched. Since
the committed git tree has no lock file, every `nix print-dev-env` evaluation
re-resolves inputs and rewrites the working-tree `flake.lock`, changing its
mtime. nix-direnv sees that mtime change and reloads on the next prompt,
printing the dev shell banner and lock update warning repeatedly.

## Acceptance Criteria

- Entering the repo runs the dev shell once; subsequent prompts do not
  re-evaluate just because `flake.lock` changed.
- `flake.lock` mtime is unchanged across two consecutive `nix print-dev-env`
  runs.
- Normal dev-shell evaluation does not print `warning: updating lock file`.
- The issue #6 autostash problem does not regress through a generated,
  unstaged lock file.
- `.gitignore` and `docs/setup.md` document the committed-lock decision.

## Current State Analysis

- `.gitignore` ignores `flake.lock` and explains the old per-project generated
  lock decision from issue #2 plus the issue #6 autostash workaround.
- `flake.lock` is not tracked in git.
- `flake.nix` uses `nixpkgs-unstable` and `flake-utils`; without a committed
  lock the inputs are resolved during each evaluation.
- `docs/setup.md` documents the dev shell but does not explain why this
  template commits its lock.

## Solution Design

Commit a complete `flake.lock` and stop ignoring it. A tracked lock is included
in the source that Nix evaluates, so Nix can reuse it instead of rewriting a
working-tree lock on each evaluation. This preserves reproducible template dev
shells and keeps nix-direnv's watched file mtimes stable.

Template consumers can still refresh pins explicitly with `nix flake update`
after creating a project from the template.

## Implementation Plan

### Step 1: Track the Nix lock file

**Files:** `flake.lock`, `.gitignore`

**Changes:**

- Generate and commit `flake.lock` for the current `flake.nix` inputs.
- Remove the `flake.lock` ignore entry and replace the old comment with a short
  note explaining that the lock is intentionally committed for nix-direnv
  stability and reproducibility.

### Step 2: Update setup documentation

**File:** `docs/setup.md`

**Changes:**

- Add a short Nix/direnv note documenting that `flake.lock` is committed on
  purpose.
- Explain that new projects can run `nix flake update` to refresh pins.

### Step 3: Verify behaviour

**Files:** none

**Validation:**

```bash
nix flake lock
nix flake check
before=$(stat -c %Y flake.lock); nix print-dev-env >/tmp/template-print-dev-env-1.out 2>&1; after=$(stat -c %Y flake.lock); test "$before" = "$after"
before=$(stat -c %Y flake.lock); nix print-dev-env >/tmp/template-print-dev-env-2.out 2>&1; after=$(stat -c %Y flake.lock); test "$before" = "$after"
! grep -q "warning: updating lock file" /tmp/template-print-dev-env-1.out /tmp/template-print-dev-env-2.out
pre-commit run --all-files
```

## Files Expected To Change

1. `.gitignore`
2. `docs/setup.md`
3. `flake.lock`
4. `docs/plan/issues/14_fix_nix_direnv_reload_loop.md`

## Risks and Open Questions

- Committing `flake.lock` reverses the issue #2 template decision. The issue
  evidence shows that decision is incompatible with nix-direnv's watched lock
  behaviour, so the reversal is intentional.
- Nix commands can take time on first evaluation if dependencies are not cached.
- The original issue #6 autostash regression should be mitigated because a
  tracked lock is not auto-staged as an intent-to-add file.

## Plan Review

**Reviewer:** Codex workflow-issue-fix

- Iteration 1: Updated validation to capture stderr from `nix print-dev-env`;
  otherwise warnings could be missed.
- Iteration 2: Approved. The expected file list covers the issue scope, the
  validation checks the mtime loop directly, and the documentation change makes
  the issue #2/#6 decision reversal explicit.
- Implementation note: Updated local validation commands to use GNU
  `stat -c %Y`, which is the `stat` available in this environment.

## Validation Results

- `nix flake check` passed.
- Two consecutive `nix print-dev-env` runs left `flake.lock` mtime unchanged.
- Combined stdout/stderr from both `nix print-dev-env` runs contained no
  `warning: updating lock file` message.
- `pre-commit run --all-files` passed.
- `git ls-files --stage flake.lock` showed `flake.lock` staged as a normal
  tracked file, not an intent-to-add entry.

## Outcome

Committed `flake.lock`, removed the ignore rule that made Nix regenerate the
lock on each evaluation, and documented the committed-lock policy for template
consumers.
