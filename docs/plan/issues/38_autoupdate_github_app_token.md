---
status: Complete
---

# Issue #38: GitHub App token for pre-commit autoupdate

**Issue:** [denhamparry/template#38](https://github.com/denhamparry/template/issues/38)
**Evidence refreshed:** 2026-11-03 UTC. The issue body and its [2026-10-10 owner comment](https://github.com/denhamparry/template/issues/38#issuecomment-6102170435) were read together.

## Problem and approach

The weekly autoupdate workflow used a long-lived `PAT_TOKEN`. Its replacement
must mint a GitHub App installation token scoped to this repository, reject
incomplete App credentials, prove an update-bearing scheduled run, remove the
PAT fallback and secret, and update the fleet tracker. The original maintenance
blocker [#148](https://github.com/denhamparry/maintenance/issues/148) was
resolved before the [App-first port, PR #39](https://github.com/denhamparry/template/pull/39).
The [App-only cleanup, PR #48](https://github.com/denhamparry/template/pull/48)
removed the fallback and updated the setup guidance.

This closing change refreshes this plan with the final evidence. The expected
changed file is this plan only; the workflow and setup documentation are already
on `main`.

## Issue traceability and acceptance

| Issue item | Disposition and evidence | Verification / result |
| --- | --- | --- |
| App token scoped to this repository; no workflow `PAT_TOKEN` references after cleanup | Implemented by PRs #39 and #48. Current workflow derives the repository name from `GITHUB_REPOSITORY`, passes it to the pinned App-token action, requests only contents and pull-requests write, and passes the minted token to `create-pull-request`. | Pre-merge repository inspection: complete. `rg -n 'PAT_TOKEN' .github/workflows` has no matches. |
| App-only selects the App path; partial App configuration fails | PR #39 exercised all credential combinations with fake values. PR #48 exercised the required-both check with all four set/unset combinations. The current check fails if either value is absent. | Pre-merge fixture and current-workflow review: complete. |
| Scheduled run executes token mint and PR creation successfully | [Scheduled run 41607691923](https://github.com/denhamparry/template/actions/runs/41607691923) on 2026-11-03 completed successfully; both `Generate GitHub App token` and `Create pull request` completed successfully. It ran the App-first workflow before PR #48 removed the unreachable PAT fallback. | Hosted operational evidence: complete. No hook change was manufactured for validation. |
| Remove the `PAT_TOKEN` Actions secret | Live Actions secret names include `APP_PRIVATE_KEY` and no `PAT_TOKEN`; live variable names include `APP_CLIENT_ID` (checked 2026-11-03). | Hosted configuration evidence: complete. Secret values were not read. |
| Update maintenance#126 with run evidence for the template tracker row | The [owner's 2026-11-03 comment](https://github.com/denhamparry/maintenance/issues/126#issuecomment-6601905412) cites run 41607691923. The `template` row in `docs/repository-standards.md` records the App-only credential, run, PAT removal, and owner-confirmed revocation. | External tracker readback: complete; maintenance#126 is closed. |
| Owner App installation, credential provisioning, and fleet PAT revocation | Completed externally. Names-only repository configuration and the scheduled run prove this repository's App path; the maintenance tracker records owner-confirmed PAT revocation across the fleet. | Operator-owned acceptance: complete as recorded by the owner; no private key or token value is retained here. |
| Keep `runs-on: ubuntu-latest`; do not force hook changes | Validated without change in the current workflow and scheduled-run history. | Pre-merge inspection: complete. |

## Closing change and validation

1. Refresh this plan's historical status and traceability against the live issue,
   current workflow, run steps, Actions credential names, and fleet tracker.
2. Review the plan diff for factual accuracy and scope. Run the repository's
   required `pre-commit run --all-files` gate on the staged handoff.
3. Publish a documentation-only PR with `Closes #38`; verify its stored closing
   reference and required checks. Leave merge to the repository owner.

The evidence is distributed across merged code, hosted run history, and
owner-managed configuration. A future credential rotation or workflow edit can
change live state, so the hosted observations above are explicitly dated.
