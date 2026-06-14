# Changelog

All notable changes to this project are documented in this file. It is updated
automatically by the release workflow from [Conventional Commit](https://www.conventionalcommits.org)
messages, and each version corresponds to a GitHub Release.


## [0.1.0] — 2026-06-14

### Features

- Establish hardened fork with owned CI/release pipeline and OSS scaffolding (#1)
- Add SYNC_MODE and SYNC_CONFIGS env vars for ob sync-config
- Add PUID/PGID support, CI build+Trivy SARIF workflow

### Bug Fixes

- Address second review round — conditional chown, VAULT_PATH everywhere, Dockerfile fix, entrypoint warnings
- Address review feedback — fail-fast scripts, lowercase image name, correct privilege model docs
- Remove node user/group before creating obsidian (GID 1000 conflict), update all actions to latest, add build-before-commit rule to AGENTS.md
- Eliminate shell injection in init-setup-vault, add comments
- Docker/metadata-action enable attribute must be boolean, not version string (#2)
- Use lts

### Refactoring

- Rewrite to s6-overlay v3 rootless architecture

### Maintenance

- Link GHCR package to repo and add CodeRabbit config (#2)
- Update CI actions to latest versions

### Other Changes

- Chown vault path + update workflow actions (pending)
- Add SLSA attestation and automated obsidian-headless version tracking (#1)
- Add Podman quadlet and document Podman usage
- Document PUID/PGID ownership and E2E encryption in README
- Add container_name
- Add PUID and PGID support
- Updated with support for e2ee
- Update to fix get-token workflow
- Add Docker setup with GHCR publish workflow for obsidian-headless continuous sync
- Initial commit
