# Security Policy

## Scope

This is a Docker image that runs [obsidian-headless](https://github.com/obsidianmd/obsidian-headless)
(the `ob` CLI) under [s6-overlay](https://github.com/just-containers/s6-overlay)
to continuously sync an Obsidian vault. The attack surface this repository owns:

- **The Dockerfile** — base image, the `obsidian-headless` install, user/UID
  setup, and build-time ownership of the vault and config directories
- **s6-overlay init/service scripts** (`rootfs/`) — the auth check, `ob login`,
  `ob sync-setup`/`sync-config`, and the supervised `ob sync --continuous`
- **Credential handling** — `OBSIDIAN_AUTH_TOKEN` and `VAULT_PASSWORD` are passed
  via environment/`.env`, never baked into the image
- **CI/CD workflows** — GitHub Actions that build and publish the image to GHCR

The `ob` binary itself is proprietary, closed-source software by Obsidian
(Dynalist Inc.); vulnerabilities in the CLI should be reported to Obsidian.

## Automated scanning

- **Gitleaks** — secret detection over full history on every PR and push to main
- **Trivy** — image vulnerability scan: PR-built images on every PR (fixable
  CRITICAL/HIGH findings block the merge), and the published GHCR image on pushes
  to main and weekly. Findings report to the
  [Security tab](https://github.com/aliasunder/obsidian-headless-sync-docker/security)
- **OpenSSF Scorecard** — supply-chain posture analysis, weekly and on pushes to main
- **Dependabot** — weekly updates for GitHub Actions and the Docker base image

Base-image CVEs surfaced by Trivy are handled through base-image and package
updates (the image runs `apk upgrade` at build time). A report is still welcome
if you've found a specific exploit path.

## Reporting a vulnerability

Please report security issues through
[GitHub's private vulnerability reporting](https://github.com/aliasunder/obsidian-headless-sync-docker/security/advisories/new)
rather than opening a public issue.

Please include:

- A description of the vulnerability
- Steps to reproduce or a proof of concept
- The potential impact

You should receive an acknowledgment within **48 hours**, and I'll coordinate a
fix before any public disclosure.

## Supported versions

Only the latest released image tag is actively maintained. Please upgrade before
reporting.

| Version | Supported |
| ------- | --------- |
| Latest  | Yes       |
| Older   | No        |
