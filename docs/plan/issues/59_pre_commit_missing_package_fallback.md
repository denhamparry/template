---
status: Complete
---

# Issue #59: Fall back when the pre-commit package path moves

**Issue:** [denhamparry/template#59](https://github.com/denhamparry/template/issues/59)
**Snapshot:** 2026-11-13 UTC; issue body, labels, and comments fetched; no comments.

## Problem and approach

The temporary `pre-commit` overlay imports a fixed nixpkgs package path before
testing its arguments. If nixpkgs moves that file, flake evaluation fails before
the intended fallback to `prev.pre-commit`. Bind the package path once and test
`builtins.pathExists` before importing it. Keep the existing override and lock.

## Issue traceability and acceptance

| Issue item | Disposition | Timing, owner, prerequisite, evidence and current result |
| --- | --- | --- |
| `nix flake check --no-build` at committed lock | Implement here. | Pre-merge, Codex; committed lock check passed. |
| Same check at nixpkgs `4fe25e12eb9f4c744966dd3de5a05246cf098601` | Implement here. | Pre-merge, Codex; input override check passed. |
| Darwin shell dry run at that revision lists no `dotnet-*` derivations | Validate without change. | Pre-merge, Codex; dry run listed only `nix-shell.drv`; passed. |
| Missing package path returns `prev.pre-commit` without an error | Implement here. | Pre-merge, Codex; temporary stub nixpkgs failed on original path import, then returned `fallback-pre-commit` after guard; passed. |
| `flake.nix:24` guard and `docs/setup.md:116` update guidance | Implement guard; validate guidance without change. | Pre-merge, Codex; reviewed guard and existing update guidance; passed. |
| Alternative `prev.pre-commit.override.__functionArgs` strategy | Not applicable. | The path guard is the smaller proposed fix and retains the current override behavior. |
| #58 review and #54 context | Validate without change. | Pre-merge, Codex; original override remains and reported revision dry run still excludes .NET; passed. |

## Implementation and validation

Expected files: `flake.nix` and this plan. First use a temporary stub nixpkgs
flake whose `outPath` lacks the package file; evaluate this flake with
`--override-input` and assert the stub `prev.pre-commit` is returned. Confirm
the original flake fails that check, then add the existence guard and repeat.
Run `nix-instantiate --parse flake.nix`, both requested `nix flake check
--no-build` variants, and the requested Darwin shell dry run. Inspect the full
branch diff and run staged all-file pre-commit hooks before committing.

Nix and pre-commit are locally installed. The fixture needs no server, service,
or generated repository artifact; it lives in a bounded temporary directory
and is removed after testing. Input downloads and hook caches may be needed.
These are local evaluation checks; no target VM command or operator acceptance
is involved. The hard-coded package path remains an upstream layout assumption,
but the missing-file case will safely fall through.

The branch review classified `flake.nix` as code-relevant. The complete change,
upstream override path, short-circuit behavior, fixture failure and success,
and related #54 workaround were inspected; no blocking finding or follow-up
idea was identified. No optional Trail of Bits skill was needed.
