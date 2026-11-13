---
status: Complete
---

# Issue #54: Avoid source-built .NET in the template shell

**Issue:** [denhamparry/template#54](https://github.com/denhamparry/template/issues/54)
**Snapshot:** 2026-11-13 UTC; issue body read, no comments.

## Problem and approach

At nixpkgs `4fe25e12eb9f4c744966dd3de5a05246cf098601`, the upstream
`pre-commit` derivation can require a source-built .NET SDK for package tests.
Adapt the override validated in denhamparry/nix#535 to this template's single
development shell. Preserve the committed `flake.lock` and its documented
update policy; the issue's unpinned-lock description predates that change.

## Issue traceability and acceptance

| Issue item | Disposition | Timing, owner, prerequisite, evidence and result |
| --- | --- | --- |
| Fresh-input Darwin shell dry run omits `dotnet-*` derivations | Implement here. | Pre-merge, Codex; reported revision produced six .NET derivations before change and only `nix-shell` after; shell derivation requisites contain no .NET. Pass. |
| Shell loads without source-building .NET | Implement here. | Pre-merge, Codex; `nix develop` completed at reported revision; pass. |
| `pre-commit --version` works and all-file hooks pass | Implement here. | Pre-merge, Codex; shell reports 4.7.0 at reported revision and 4.5.1 at committed lock; all-file hooks passed on final staged snapshot. |
| Preserve lockfile policy | Validate without change. | Pre-merge, Codex; tracked `flake.lock`, `.gitignore`, and `docs/setup.md` inspected; lock remains at `f205b55` and default shell works; pass. |
| Document override removal condition | Implement here. | Pre-merge, Codex; `flake.nix` TODO tied to upstream Darwin cache availability; pass. |
| Assess template-derived repositories separately | Intentionally out of scope for this repository PR. | External repository owners; check each consumer's nixpkgs revision and shell independently. |
| Related maintenance#176 and nix#534/#535 fixes | Validate provenance without change. | Pre-merge, Codex; compared merged nix#535 override and the template shell; pass. |

## Implementation and validation

Expected files: `flake.nix` and this plan. Add a conditional overlay for
`pre-commit`, import nixpkgs with it, and retain the existing shell packages.
The committed nixpkgs revision's package has no `dotnetCorePackages` parameter,
so the overlay passes it only when the upstream package function declares it.
Use `--override-input nixpkgs github:NixOS/nixpkgs/4fe25e12eb9f4c744966dd3de5a05246cf098601`
to test the reported newer revision without writing `flake.lock`. First capture
the original dry run, then check the corrected dry run, inspect the derivation
requisites if the dry-run build list is insufficient, enter the shell, run its
version command, and run all-file hooks. Run Nix parse/format checks and review
the complete diff. No server or service prerequisites exist; Nix downloads
and pre-commit hook caches may be needed. Temporary Nix outputs are automatic
store objects; no repository cleanup is planned.

The original dry run at the reported revision reproduced six `dotnet-*`
derivations plus `pre-commit` and the shell. The upstream override targets the
package test dependency; the guard preserves the older committed-lock shell.
`nix fmt` was unavailable because this flake defines no formatter; Nix parsing
and repository hooks cover the changed files instead.
An independent read-only review found no blocking issue. The guard reads the
upstream package function from its current nixpkgs path, so a future nixpkgs
layout change must be considered when updating or removing this workaround.

The override changes package test inputs. Check that it only changes the
selected `pre-commit` derivation and does not alter other shell packages or
lock state. Remove it when a freshly resolved upstream `pre-commit` for
`aarch64-darwin` is available from `cache.nixos.org` without source-built
.NET requisites; verify with `nix path-info --store https://cache.nixos.org`
and a dry run before removal.
