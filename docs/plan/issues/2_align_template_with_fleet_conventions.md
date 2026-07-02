# GitHub Issue #2: Review template repo and align it with fleet conventions

**Issue:** [#2](https://github.com/denhamparry/template/issues/2)
**Status:** Complete
**Date:** 2026-07-02

## Problem Statement

This template is the starting point for new Claude Code projects, but several
conventions that are now standard across the denhamparry repo fleet (`claude`,
`homelab`, `cfp`, `website`, `dotfiles`) haven't made it back into the
template. New projects created from the template start behind the fleet
standard and need manual retrofitting.

### Current Behavior

- The template ships `.pre-commit-config.yaml` but no workflow runs the hooks:
  `ci.yml` is a placeholder job that always passes.
- No `@claude` mention workflow exists; the template ships only the dormant
  `.github/claude-code-review.yml` config, while the fleet has moved to
  opt-in mention-based reviews.
- No weekly pre-commit hook autoupdate.
- No CODEOWNERS, SECURITY.md, link checking, or Scorecard.
- Commented action examples in `ci.yml` use mutable tags (`@v4`) instead of
  the fleet's SHA-pinned convention.
- No `AGENTS.md` symlink (Codex CLI portability) and no reproducible dev
  shell (`flake.nix`).
- `docs/plan.md` and `docs/progress.md` are 2025-10-02 planning artifacts
  from building the template itself and get inherited by every new project.
- `CLAUDE.md` footer is stale (`Template Version: 1.0`, placeholder
  maintainer).

### Expected Behavior

A repository created from this template starts with the same CI, governance,
and agent-tooling baseline as the rest of the fleet: pre-commit as the
required check, mention-based Claude reviews, weekly hook updates, link
checking, Scorecard, CODEOWNERS, SECURITY.md, documented branch protection,
YAML issue forms, `AGENTS.md`, and an opt-in nix dev shell — with no leftover
template-development artifacts.

## Current State Analysis

### Relevant Code/Config

- `.github/workflows/ci.yml` — placeholder job only; commented examples use
  `actions/checkout@v4` (tag, not SHA).
- `.github/workflows/auto-assign-prs.yml` — already consistent with the fleet
  (verified 2026-07-02 across all 28 active repos); no change needed.
- `.github/claude-code-review.yml` — auto-review config with no workflow that
  consumes it; the `claude` repo has the equivalent workflow disabled in
  favour of mention-based `claude.yml`.
- `.github/ISSUE_TEMPLATE/*.md` — legacy markdown issue templates.
- `.github/dependabot.yml` — fine as-is (github-actions ecosystem enabled).
- `docs/plan.md`, `docs/progress.md` — template-development artifacts.
- `.gitignore` — only ignores `.env`; needs nix/direnv entries once
  `flake.nix` lands.

### Related Context

- Fleet reference implementations fetched from `denhamparry/claude`
  `.github/workflows/`: `pre-commit.yml`, `pre-commit-autoupdate.yml`,
  `claude.yml`, `links.yml`, `scorecard.yml`, plus `flake.nix`. These are the
  source of truth for pinned action SHAs and structure.
- Fleet repos run on `[self-hosted, bear]`; the template must default to
  `ubuntu-latest` since new projects won't have the self-hosted runner.
- Branch protection convention (from `claude` repo): `pre-commit` is the only
  required status check; path-filtered workflows must not be required.

## Solution Design

### Approach

Port the fleet's proven workflow files into the template, adapted for
general use (`ubuntu-latest`, customisation comments), add the missing
governance files, convert issue templates to YAML forms, add agent-tooling
portability files, document branch protection, and remove stale artifacts.

Rationale: copying the battle-tested files from `denhamparry/claude`
guarantees convention alignment (including exact pinned SHAs) rather than
reinventing similar workflows that drift.

Trade-offs considered:

- **Scorecard on private repos** — the action requires public repos for
  `publish_results`. Ship it with a header comment telling users of private
  repos to delete it (matches "opt-in for public repos" from the issue).
- **`claude-code-review.yml` (auto-review config)** — keep the file (the
  setup wizard references it and some users may want auto-reviews), but ship
  `claude.yml` (mention-based) as the fleet-standard default and document
  the distinction.
- **`flake.nix`** — opt-in; non-nix users are unaffected. `.envrc` activates
  it only for direnv users.

### Implementation

Adapted fleet workflows (all `runs-on: ubuntu-latest`, SHA-pinned actions
with version comments), new governance files, YAML issue forms, `AGENTS.md`
symlink, `flake.nix` + `.envrc`, docs updates, artifact cleanup.

### Benefits

- New projects start at fleet baseline — zero retrofitting.
- `pre-commit` becomes a real, requirable status check.
- Security posture: pinned actions, Scorecard, SECURITY.md, documented
  branch protection.

## Implementation Plan

### Step 1: Add pre-commit CI workflow

**File:** `.github/workflows/pre-commit.yml` (new)

**Changes:**

- Port from `denhamparry/claude`, changing `runs-on` to `ubuntu-latest` and
  dropping the self-hosted cache comment.
- Triggers: `pull_request` (opened/synchronize/reopened) + `push` to `main`;
  concurrency cancel-in-progress; `permissions: contents: read`.
- Steps: checkout (`actions/checkout@9c091bb…v7.0.0`, `fetch-depth: 0` for
  gitleaks), setup-python (`@ece7cb0…v6.3.0`, 3.12), setup-node
  (`@48b55a0…v6.4.0`, 22), `pip install pre-commit`,
  `pre-commit run --all-files --show-diff-on-failure`.
- Header comment: this is the intended required status check.

**Testing:** `pre-commit run --all-files` locally; YAML syntax validated by
the `check-yaml` hook.

### Step 2: Add pre-commit autoupdate workflow

**File:** `.github/workflows/pre-commit-autoupdate.yml` (new)

**Changes:**

- Port from `denhamparry/claude`; `runs-on: ubuntu-latest`.
- Weekly Tuesday 09:00 UTC + `workflow_dispatch`; runs
  `pre-commit autoupdate`, validates, opens a PR via
  `peter-evans/create-pull-request@5f6978f…v8.1.1`.
- Keep `assignees: denhamparry` (consistent with `auto-assign-prs.yml`) with
  a comment telling template users to customise.

### Step 3: Add mention-based Claude workflow

**File:** `.github/workflows/claude.yml` (new)

**Changes:**

- Port from `denhamparry/claude`; `runs-on: ubuntu-latest`; keep the
  `@claude` mention gate across issue comments, PR review comments, PR
  reviews, and issues; minimal job-level permissions.
- Uses `anthropics/claude-code-action@725b9c3…v1` with
  `claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}`.
- Header comment: requires the `CLAUDE_CODE_OAUTH_TOKEN` secret (run
  `/install-github-app` in Claude Code to set up).

### Step 4: Add link check workflow

**File:** `.github/workflows/links.yml` (new)

**Changes:**

- Port from `denhamparry/claude`; `runs-on: ubuntu-latest`.
- PR runs: offline internal-link check on `**/*.md`; weekly Monday 10:00
  UTC: full external check that opens an issue on failure. Uses
  `lycheeverse/lychee-action@8646ba3…v2.8.0`.
- Add `.lycheeignore` (new) excluding template placeholder URLs
  (`github.com/YOUR_USERNAME/`, `github.com/your-username/`,
  `github.com/[OWNER]/`) so the weekly external check doesn't open noise
  issues on unmodified templates (review finding).

### Step 5: Add OpenSSF Scorecard workflow

**File:** `.github/workflows/scorecard.yml` (new)

**Changes:**

- Port from `denhamparry/claude` (already `ubuntu-latest`).
- Add header comment: designed for public repos; delete this file (or expect
  failures) on private repos without GitHub Advanced Security.

### Step 6: SHA-pin examples in ci.yml

**File:** `.github/workflows/ci.yml`

**Changes:**

- Replace commented `uses: actions/checkout@v4` examples with the pinned
  `actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0` form.
- Update the placeholder note to mention that pre-commit checks now live in
  `pre-commit.yml` and this file is for project build/test/lint jobs.

### Step 7: Add CODEOWNERS

**File:** `.github/CODEOWNERS` (new)

**Changes:**

- `* @denhamparry` with a comment telling template users to replace the
  handle. Complements `auto-assign-prs.yml` by making review requests native
  for human-authored PRs.

### Step 8: Add SECURITY.md

**File:** `SECURITY.md` (new)

**Changes:**

- Short policy: report via GitHub private vulnerability reporting
  (Security → Report a vulnerability), expected response time, supported
  versions table placeholder, no public issue disclosure.

### Step 9: Convert issue templates to YAML forms

**Files:** `.github/ISSUE_TEMPLATE/bug_report.yml` (new),
`.github/ISSUE_TEMPLATE/feature_request.yml` (new),
`.github/ISSUE_TEMPLATE/bug_report.md` (delete),
`.github/ISSUE_TEMPLATE/feature_request.md` (delete)

**Changes:**

- Recreate the same fields as structured issue forms (textarea/input fields,
  required flags, labels preserved). `config.yml` unchanged.

### Step 10: Add AGENTS.md symlink

**File:** `AGENTS.md` (new symlink → `CLAUDE.md`)

**Changes:**

- Committed relative symlink so Codex CLI reads the same project
  instructions (fleet portability pattern).

### Step 11: Add nix dev shell (opt-in)

**Files:** `flake.nix` (new), `.envrc` (new), `.gitignore`

**Changes:**

- Port `flake.nix` from `denhamparry/claude` with template-appropriate
  description; same toolset (pre-commit, node, prettier, markdownlint,
  shellcheck, gitleaks, gh).
- `.envrc`: `use flake`.
- `.gitignore`: add `.direnv/` and `result`.
- No `flake.lock` committed — first `nix develop` generates it per-project.

### Step 12: Document branch protection

**File:** `docs/setup.md`

**Changes:**

- New "Branch Protection" section: require `pre-commit` as the only required
  status check (path-filtered workflows must not be required), ≥1 review,
  branches up to date, block direct pushes/force pushes; include the
  `gh api` command to apply the ruleset.
- Update the GitHub Integration section to describe mention-based `@claude`
  reviews via `claude.yml` and the `CLAUDE_CODE_OAUTH_TOKEN` secret.

### Step 13: Update setup wizard

**File:** `.claude/commands/setup-repo.md`

**Changes:**

- Add wizard steps: customise CODEOWNERS, set the autoupdate assignee,
  confirm/delete `scorecard.yml` for private repos, set up
  `CLAUDE_CODE_OAUTH_TOKEN`, and apply branch protection after first push.

### Step 14: Clean up template-development artifacts

**Files:** `docs/plan.md` (delete), `docs/progress.md` (delete)

**Changes:**

- Remove both; they describe building the template itself (all Phase 1 items
  complete). Anything outstanding is superseded by issue #2.

### Step 15: Refresh CLAUDE.md and README.md

**Files:** `CLAUDE.md`, `README.md`

**Changes:**

- `CLAUDE.md`: update Template Contents to list the new files/workflows,
  describe mention-based reviews, bump footer to `Template Version: 1.1`,
  `Last Updated: 2026-07-02`, `Maintained By: Lewis Denham-Parry`.
- `README.md`: update the "what's included" overview to mention the CI
  workflows and governance files.

## Testing Strategy

### Unit Testing

Not applicable — configuration and documentation only. Validation is via
pre-commit hooks (check-yaml, markdownlint, prettier, gitleaks).

### Integration Testing

**Test Case 1: Pre-commit passes on the branch**

1. Run `pre-commit run --all-files` twice (auto-fix, then verify).
2. Expected: all hooks pass on second run.

**Test Case 2: Workflow YAML is valid**

1. `check-yaml` hook validates all new workflow files.
2. Expected: no syntax errors.

**Test Case 3: AGENTS.md symlink resolves**

1. `test "$(readlink AGENTS.md)" = "CLAUDE.md"` and the target exists.
2. Expected: symlink resolves to CLAUDE.md.

**Test Case 4: Issue forms schema**

1. YAML forms include `name`, `description`, `body` keys; `check-yaml`
   passes.
2. Expected: valid issue-form structure.

### Regression Testing

- `auto-assign-prs.yml` and `dependabot.yml` unchanged.
- `ci.yml` placeholder job still passes (only comments/messaging change).
- Existing docs links still resolve (verified by lychee offline mode
  locally if available; otherwise by inspection).

## Success Criteria

- [ ] Five new workflows added (`pre-commit`, `pre-commit-autoupdate`,
      `claude`, `links`, `scorecard`), all SHA-pinned, `ubuntu-latest`
- [ ] `ci.yml` examples SHA-pinned
- [ ] CODEOWNERS and SECURITY.md present
- [ ] Issue templates converted to YAML forms (old `.md` removed)
- [ ] `AGENTS.md` symlink and `flake.nix`/`.envrc` present
- [ ] Branch protection documented in `docs/setup.md`
- [ ] Setup wizard covers the new files
- [ ] `docs/plan.md` and `docs/progress.md` removed
- [ ] `CLAUDE.md`/`README.md` refreshed
- [ ] Pre-commit hooks pass on all files

## Files Modified

1. `.github/workflows/pre-commit.yml` - New: pre-commit CI (required check)
2. `.github/workflows/pre-commit-autoupdate.yml` - New: weekly hook updates
3. `.github/workflows/claude.yml` - New: mention-based Claude reviews
4. `.github/workflows/links.yml` - New: lychee link checking
5. `.github/workflows/scorecard.yml` - New: OpenSSF Scorecard (public repos)
6. `.github/workflows/ci.yml` - SHA-pin commented examples; clarify role
7. `.github/CODEOWNERS` - New: default owner @denhamparry
8. `SECURITY.md` - New: vulnerability disclosure policy
9. `.github/ISSUE_TEMPLATE/bug_report.yml` - New: YAML issue form
10. `.github/ISSUE_TEMPLATE/feature_request.yml` - New: YAML issue form
11. `.github/ISSUE_TEMPLATE/bug_report.md` - Deleted (replaced by form)
12. `.github/ISSUE_TEMPLATE/feature_request.md` - Deleted (replaced by form)
13. `AGENTS.md` - New symlink → CLAUDE.md
14. `flake.nix` - New: reproducible dev shell
15. `.envrc` - New: direnv activation
16. `.gitignore` - Add `.direnv/`, `result`
17. `docs/setup.md` - Branch protection + mention-based review docs
18. `.claude/commands/setup-repo.md` - Wizard steps for new files
19. `docs/plan.md` - Deleted (template-development artifact)
20. `docs/progress.md` - Deleted (template-development artifact)
21. `CLAUDE.md` - Contents list + footer refresh
22. `README.md` - Feature overview refresh
23. `.lycheeignore` - New: exclude template placeholder URLs (review finding)

## Related Issues and Tasks

### Depends On

- None — all reference material available in `denhamparry/claude`.

### Blocks

- Future template consumers inheriting fleet conventions.

### Related

- Fleet audit (2026-07-02) confirming `auto-assign-prs.yml` consistency.
- `denhamparry/claude` issue #123 (branch protection rules reference).

### Enables

- `/setup-repo` wizard producing fleet-baseline projects out of the box.

## References

- [GitHub Issue #2](https://github.com/denhamparry/template/issues/2)
- `denhamparry/claude` `.github/workflows/` — reference implementations
- [OpenSSF Scorecard action](https://github.com/ossf/scorecard-action)
- [GitHub issue forms syntax](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)

## Notes

### Key Insights

- Copying pinned SHAs from the `claude` repo keeps Dependabot histories
  aligned across the fleet — the same digest bumps land everywhere.
- `runs-on` is the only intentional fleet variance: infra repos use
  `[self-hosted, bear]`; the template must default to `ubuntu-latest`.
- Scorecard is the only workflow with a public-repo constraint; a header
  comment is cheaper than conditional logic GitHub Actions can't express.

### Alternative Approaches Considered

1. **Write new workflows from scratch** - Rejected: guarantees drift from
   the fleet; the issue is explicitly about alignment ❌
2. **Make the template consume reusable workflows from a central repo** -
   Rejected for now: adds a cross-repo dependency and the fleet doesn't use
   `workflow_call` yet; worth revisiting as a follow-up ❌
3. **Port fleet files with `ubuntu-latest` adaptation** - Chosen: proven
   files, exact SHA alignment, minimal invention ✅

### Best Practices

- Keep the template's pinned SHAs fresh via Dependabot (already configured
  for `github-actions`).
- When the fleet convention changes, update the template in the same sweep.

## Plan Review

**Reviewer:** Claude Code (workflow-research-plan)
**Review Date:** 2026-07-02
**Original Plan Date:** 2026-07-02

### Review Summary

- **Overall Assessment:** Approved
- **Confidence Level:** High
- **Recommendation:** Proceed to implementation (required changes are folded
  into the plan above and must be honoured during implementation)

### Strengths

- Ports battle-tested workflow files from `denhamparry/claude` rather than
  reinventing them, so pinned SHAs and structure stay aligned with the
  fleet by construction.
- Correctly identifies `runs-on` as the only intentional fleet variance and
  defaults the template to `ubuntu-latest` (verified: the four repos using
  `[self-hosted, bear]` differ from the fleet file by exactly that line).
- Scope matches issue #2 one-to-one: every checkbox in the issue maps to a
  numbered implementation step; nothing extra is smuggled in.
- Deletion safety verified: `docs/plan.md` and `docs/progress.md` are not
  referenced by any other markdown file.

### Gaps Identified

1. **Gap 1:** Placeholder URLs break the weekly external link check.
   `README.md` and `CONTRIBUTING.md` contain deliberate placeholder links
   (`github.com/YOUR_USERNAME/REPO_NAME.git`,
   `github.com/your-username/your-new-project.git`) that will 404, so the
   scheduled lychee run would open a noise issue on every unmodified
   template clone.
   - **Impact:** Medium
   - **Recommendation:** Add `.lycheeignore` with placeholder patterns —
     folded into Step 4 and Files Modified (item 23).
2. **Gap 2:** `claude-code-review.yml` is referenced in `CLAUDE.md` (3
   places), `README.md`, and `docs/setup.md`. Adding `claude.yml` without
   updating those references would leave the docs presenting auto-review as
   the primary path, contradicting the fleet convention.
   - **Impact:** Medium
   - **Recommendation:** Steps 12 and 15 must explicitly reposition
     mention-based `@claude` review as primary and auto-review config as
     optional.

### Edge Cases Not Covered

1. **Edge Case 1:** Windows checkouts of the `AGENTS.md` symlink require
   Developer Mode or `core.symlinks=true`.
   - **Current Plan:** Not mentioned.
   - **Recommendation:** Acceptable residual risk for this fleet (macOS /
     Linux); no change required. Note only.
2. **Edge Case 2:** Autoupdate PRs created with the default `GITHUB_TOKEN`
   won't trigger the pre-commit check (GitHub anti-recursion).
   - **Current Plan:** Covered — the ported file's header documents the
     close/reopen workaround and PAT alternative.

### Alternatives Assessed During Review

1. **Central reusable workflows (`workflow_call`)**
   - **Pros:** Single point of update for the whole fleet.
   - **Cons:** Cross-repo coupling; fleet doesn't use it yet; template users
     outside the fleet would depend on `denhamparry` repos.
   - **Verdict:** Plan's copy-with-adaptation approach is right for now;
     revisit as a follow-up idea.

### Risks and Concerns

1. **Risk 1:** Hooks that rewrite files (`end-of-file-fixer`,
   `trailing-whitespace`) follow symlinks and could materialise `AGENTS.md`
   as a regular file if `CLAUDE.md` ever fails those hooks.
   - **Likelihood:** Low (CLAUDE.md already passes; same pattern works in
     the `claude` repo with more aggressive hooks)
   - **Impact:** Low
   - **Mitigation:** None needed now; verify symlink intact in Test Case 3.
2. **Risk 2:** `scorecard.yml` fails on private template clones.
   - **Likelihood:** High for private clones
   - **Impact:** Low (non-required check)
   - **Mitigation:** Header comment + setup wizard step to delete it
     (Steps 5 and 13).

### Required Changes

**Changes that must be made before implementation:**

- [x] Add `.lycheeignore` for placeholder URLs (folded into Step 4 / Files
      Modified item 23)
- [x] Update all `claude-code-review.yml` references in `CLAUDE.md`,
      `README.md`, and `docs/setup.md` to present mention-based review as
      primary (clarified in Steps 12 and 15)

### Optional Improvements

- [ ] After merge, apply the documented branch protection to this template
      repo itself (out-of-band `gh api` call)
- [ ] Consider a `nix.yml` advisory flake check if `flake.nix` sees real use

### Verification Checklist

- [x] Solution addresses root cause identified in GitHub issue
- [x] All acceptance criteria from issue are covered
- [x] Implementation steps are specific and actionable
- [x] File paths and code references are accurate (verified against the
      worktree and `denhamparry/claude` fetched files)
- [x] Security implications considered and addressed (pinned SHAs, minimal
      permissions, gitleaks fetch-depth)
- [x] Performance impact assessed (concurrency cancellation on all new
      workflows)
- [x] Test strategy covers critical paths and edge cases
- [x] Documentation updates planned
- [x] Related issues/dependencies identified
- [x] Breaking changes documented (issue template `.md` → `.yml` swap)
