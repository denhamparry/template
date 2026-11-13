---
status: Complete
---

# Issue #57: Reuse the open broken-links issue

**Issue:** [denhamparry/template#57](https://github.com/denhamparry/template/issues/57)
**Snapshot:** 2026-11-13 UTC; issue body and labels fetched, with no comments.

## Problem and approach

The scheduled Links job creates a new issue for every persistent failure. Query
open issues by title, select an exact title match, and comment with the current
run URL when one exists. Create the existing issue title and label only when no
match exists. A failed lookup must stop the step rather than create an issue.

## Issue traceability and acceptance

| Issue item | Disposition | Timing, owner, prerequisite, evidence and current result |
| --- | --- | --- |
| Exact-title open match comments once and never creates | Implemented here. | Pre-merge, Codex; extracted `run:` body with stub `gh` passed. |
| No match creates exactly once with existing title and `documentation` label | Implemented here. | Pre-merge, Codex; extracted `run:` body with stub `gh` passed. |
| `actionlint -no-color .github/workflows/links.yml` and `shellcheck -s bash` pass | Validated here. | Pre-merge, Codex; Nix actionlint and local shellcheck passed. |
| Job permissions remain `contents: read`, `issues: write` | Validated without change. | Pre-merge, Codex; job permission diff unchanged. |
| Keep new run URL visible in reused issue | Implemented here. | Pre-merge, Codex; stub assertion passed. |
| #56 and #55 are context, not additional changes | Intentionally out of scope. | Pre-merge, Codex; branch diff scoped to Links job and plan. |

## Implementation and validation

Expected files: `.github/workflows/links.yml` and this plan. Write a
failure-shaped extracted-step fixture first, then update the workflow. Exercise
match, no match, and lookup-failure paths with a stub `gh` in a temporary
directory. Run `actionlint`, `shellcheck`, and staged `pre-commit --all-files`;
inspect the complete diff and job permissions. No server or generated artifacts
are needed. Temporary fixture files are removed after testing.

The extracted-step fixture failed against the original workflow because it
created an issue when a match was supplied. It now passes for match, no match,
and lookup failure. The real read-only `gh issue list` query also succeeded.
The step runs on GitHub's `ubuntu-latest` runner, which supplies Bash and `gh`
for Actions jobs (documented by the existing workflow usage); local tests do
not prove a future scheduled failure. The hosted run remains naturally deferred
until a link failure occurs, but all required acceptance criteria are
pre-merge verifiable through the requested extracted-step fixtures.
