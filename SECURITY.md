# Security Policy

## Reporting a Vulnerability

Please **do not** open a public issue for security vulnerabilities.

Instead, use GitHub's private vulnerability reporting: go to the
**Security** tab of this repository and click **Report a vulnerability**.
This creates a private advisory visible only to the maintainers.

You can expect an initial response within 7 days. Please include:

- A description of the vulnerability and its impact
- Steps to reproduce
- Any suggested mitigations

## Supported Versions

| Version         | Supported |
| --------------- | --------- |
| latest (`main`) | ✅        |

Customise this table if your project maintains release branches.

## Security Tooling

This repository ships with security checks enabled by default:

- **gitleaks** (pre-commit + CI) — secret detection
- **OpenSSF Scorecard** (weekly) — security posture assessment
- **Dependabot** — automated dependency updates
- **SHA-pinned actions** — supply-chain protection for CI
