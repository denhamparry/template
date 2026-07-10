# Project: GitHub Template for Claude Code Projects

## Repository Purpose

This is a **GitHub template repository** designed to provide a standardized foundation for new projects that will be developed with Claude Code. It includes setup documentation and best practices for TDD-driven development with AI assistance.

## Using This Template

### For New Projects

1. Click "Use this template" on GitHub to create a new repository
2. Clone your new repository locally
3. Open Claude Code in the project directory: `claude`
4. **Run `/setup-repo`** - Interactive wizard that will:
   - Gather your project information (name, tech stack, commands)
   - Customize CLAUDE.md with your project details
   - Configure pre-commit hooks for your language
   - Set up GitHub PR review automation
   - Install and verify all configurations
5. Commit the configured files and start building with TDD!

Alternatively, you can manually follow the setup checklist in `docs/setup.md`.

### Template Contents

- `README.md` - Template overview and quick start guide
- `docs/setup.md` - Comprehensive Claude Code setup checklist (including
  branch protection)
- `CLAUDE.md` - This file (customize for your project)
- `AGENTS.md` - Symlink to CLAUDE.md (Codex CLI portability)
- `SECURITY.md` - Vulnerability disclosure policy
- `.claude/commands/` - Custom slash commands for workflows
  - `setup-repo.md` - **Interactive setup wizard (start here!)**
  - `review.md` - Comprehensive code review workflow
  - `tdd-check.md` - TDD compliance verification
  - `precommit.md` - Pre-commit hooks runner
- `.github/workflows/` - CI workflows (all actions SHA-pinned)
  - `pre-commit.yml` - Runs all quality hooks (**the required status check**)
  - `ci.yml` - Placeholder for project build/test/lint jobs
  - `auto-assign-prs.yml` - Assigns and requests review on new PRs
  - `pre-commit-autoupdate.yml` - Weekly hook version updates
  - `links.yml` - Markdown link checking (internal on PR, external weekly)
  - `scorecard.yml` - OpenSSF Scorecard (public repos; delete if private)
- `.github/CODEOWNERS` - Default reviewers (customize the handle)
- `.github/claude-code-review.yml` - Optional automated PR review configuration
- `.pre-commit-config.yaml` - Code quality hooks configuration
- `flake.nix` / `.envrc` - Opt-in reproducible dev shell (nix + direnv)

## Development Philosophy

### Test-Driven Development (TDD)

All projects created from this template should follow TDD:

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to make it pass
3. **Refactor**: Improve code while keeping tests green

### Claude Code Best Practices

- Use 3-step process: Research → Plan → Implement
- Write tests before implementation
- Commit frequently with clear messages
- Use @-mentions to include relevant files in context
- Leverage custom slash commands for common workflows

### Custom Slash Commands

This template includes custom slash commands in `.claude/commands/`:

- **`/setup-repo`** - Interactive setup wizard for new projects (run this first!)
- **`/review`** - Comprehensive code review covering quality, tests, security, performance, and documentation
- **`/tdd-check`** - Verify TDD workflow compliance (tests written before implementation)
- **`/precommit`** - Run pre-commit hooks on all files to catch quality issues

Customize these commands or add new ones for your project-specific workflows.

## Customization Checklist

When creating a new project from this template:

- [ ] Update this CLAUDE.md with project-specific information
- [ ] Add Quick Commands section with your build/test/lint commands
- [ ] Define Code Style Guidelines for your language/framework
- [ ] Document Project Structure
- [ ] Set up Testing Requirements and framework
- [ ] Configure Git Workflow and branching strategy
- [ ] Add Environment Setup instructions
- [ ] Document Common Patterns specific to your project
- [ ] List Known Issues/Gotchas
- [ ] Add Dependencies Notes
- [ ] Customize `.pre-commit-config.yaml` for your language (uncomment relevant hooks)
- [ ] Replace `@denhamparry` in `.github/CODEOWNERS`, `auto-assign-prs.yml`, and `pre-commit-autoupdate.yml` with your handle
- [ ] Provision a `PAT_TOKEN` secret for the pre-commit autoupdate workflow (or delete the workflow if not wanted)
- [ ] Delete `.github/workflows/scorecard.yml` if your project is private
- [ ] Modify or add custom slash commands in `.claude/commands/` as needed
- [ ] Install and configure pre-commit: `pip install pre-commit && pre-commit install`
- [ ] If `@claude` mentions are wanted, add the current Claude Code workflow
      and run `/install-github-app` in Claude Code to provision its repository
      secret
- [ ] Apply branch protection after first push (see `docs/setup.md` → Branch Protection)

## Quick Commands (Template Defaults)

Replace this section with your actual commands:

```bash
# Build: [Add your build command]
# Test: [Add your test command]
# Lint: [Add your lint command]
# Type Check: [Add your typecheck command]
# Dev Server: [Add your dev command]
```

## Code Style Guidelines (Customize)

- Follow TDD: Write tests first, then implementation
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- [Add language-specific conventions]

## Testing Requirements

- **TDD is mandatory**: All features must start with tests
- Write unit tests for all business logic
- Add integration tests for critical paths
- Maintain >80% code coverage
- Run tests before every commit

## Git Workflow

- Branch naming: `feature/*`, `bugfix/*`, `hotfix/*`
- Commit message format: `type: description`
  - Types: feat, fix, docs, style, refactor, test, chore
- Always create PR for review
- Rebase before merging

## Pre-commit Hooks

This template includes `.pre-commit-config.yaml` with generic code quality hooks:

- File formatting (trailing whitespace, end-of-file, line endings)
- Syntax validation (YAML, JSON, TOML, XML)
- Secret detection (gitleaks)
- Large file detection
- Merge conflict detection

**Setup:**

```bash
pip install pre-commit
pre-commit install
```

**Run manually:**

```bash
pre-commit run --all-files
```

Customize `.pre-commit-config.yaml` for your language-specific needs (Python, Go, JavaScript, etc.).

## GitHub Integration

Claude reviews are optional and mention-based. Add the current Claude Code
GitHub Actions workflow only in repositories where `@claude` reviews are
wanted, then mention `@claude` in an issue, PR comment, or review to request
help. This avoids copying an active workflow before its repository secret has
been provisioned.

**Setup:**

1. Add the current Claude Code GitHub Actions workflow from the official Claude
   Code setup flow or documentation.
2. Run `/install-github-app` in a Claude Code session — this configures the
   workflow's repository secret.
3. Mention `@claude` wherever you want a review or triage.
4. (Optional) For automatic reviews on every PR, customize
   `.github/claude-code-review.yml`

Review requests typically check for:

- Code quality and style compliance
- TDD compliance (tests written first)
- Bugs and edge cases
- Security vulnerabilities
- Performance issues
- Documentation updates

## Notes for Template Maintainers

- Keep `docs/setup.md` updated with latest Claude Code best practices
- This template should remain language-agnostic
- Focus on Claude Code integration patterns
- Update checklist based on user feedback

---

**Template Version:** 1.1
**Last Updated:** 2026-07-02
**Maintained By:** Lewis Denham-Parry
