---
status: Complete
---

# Issue #55: Exclude private maintenance links from lychee

**Issue:** [denhamparry/template#55](https://github.com/denhamparry/template/issues/55)
**Snapshot:** 2026-11-10 UTC; issue body read with no comments.

## Problem and change

The unauthenticated weekly Links job receives 404 responses for two valid links
into the private `denhamparry/maintenance` repository. Keep those provenance
links and add a commented repository-specific pattern to `.lycheeignore`.
Avoid adding credentials to the public link checker. The optional duplicate
issue guard is a separate follow-up idea because it does not affect this failure.

## Issue traceability and acceptance

| Issue item | Disposition | Timing, owner, prerequisite, evidence and current result |
| --- | --- | --- |
| Commented `.lycheeignore` pattern for private maintenance URLs | Implemented here. | Pre-merge, Codex; regex check matched both reported URLs and rejected two unrelated URLs. Lychee checked the issue #38 plan: 7 links, 5 OK, 2 excluded, 0 errors. Complete. |
| `workflow_dispatch` on `main` succeeds for `external-links` | Deferred operational validation. | Post-merge, repository owner; merged fix on `main`; run URL and job conclusion; pending. |
| Close placeholder #51 with a reference to the fix | Deferred operator action. | Post-merge, repository owner; successful `main` run; issue state and closing comment; pending. |
| Optional guard against duplicate weekly issues in `links.yml` | Non-blocking follow-up idea in PR body. | No requirement for this PR. |
| Preserve links in issue #38 plan; do not add lychee credentials | Validated without change. | Pre-merge, Codex; inspected source and workflow diff; complete. |
| Source run 42598350201 and previous success history | Diagnostic evidence; no repository change. | Pre-merge, Codex; issue snapshot; observed. |

## Implementation and validation

Expected files: `.lycheeignore` and this plan. Review `links.yml` and the issue
38 plan without modifying them. Check that the regex matches both reported
private URLs and misses public GitHub URLs. Run the repository pre-commit gate
on the staged handoff. If a lychee CLI is available, run its full Markdown
check; network responses can vary independently of this pattern. Review the
complete diff. After merge, the owner can dispatch `links.yml` on `main`,
confirm the `external-links` result, and close #51 with the successful run.

The local regex and lychee checks prove the private links are excluded. The
repository pre-commit gate passed on all files. These checks do not prove a
hosted run on `main`, so the PR must use `Refs #55` and leave issue closure
pending.
