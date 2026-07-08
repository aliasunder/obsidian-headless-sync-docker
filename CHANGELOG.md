# Changelog

All notable changes to this project are documented in this file. It is updated
automatically by the release workflow from [Conventional Commit](https://www.conventionalcommits.org)
messages, and each version corresponds to a GitHub Release.





## [0.1.3] — 2026-07-08

### Bug Fixes

- Only show error if related to encryption
- Include /vault in build-time chown for entrypoint-bypass consistency
- Chown /home/obsidian/.config at build time so named-volume mounts inherit obsidian ownership

### Documentation

- Update README and AGENTS.md for maintained fork status (#15)
- Document $ escaping needed for VAULT_PASSWORD in .env

### Maintenance

- Remove upstream update-docker-image workflow
- **deps:** Bump github/codeql-action/upload-sarif (#14)
- **deps:** Bump docker/setup-buildx-action from 4.1.0 to 4.2.0 (#13)
- **deps:** Bump docker/build-push-action from 7.2.0 to 7.3.0 (#12)
- **deps:** Bump docker/setup-qemu-action from 4.1.0 to 4.2.0 (#11)
- **deps:** Bump docker/login-action from 4.2.0 to 4.4.0 (#10)
- **deps:** Bump node from `bc23e69` to `a0b9bf0` (#9)
- **deps:** Bump actions/attest-build-provenance from 4.1.0 to 4.1.1 (#8)
- **deps:** Bump actions/checkout from 6.0.3 to 7.0.0 (#6)

### Other Changes

- Potential fix for pull request finding 'CodeQL / Workflow does not contain permissions'
- Add workflow to rebuild docker image on rootfs/Dockerfile changes
- Initial plan
- Add CONFIG_DIR_NAME support and fix missing compose env passthrough
- Initial plan

## [0.1.2] — 2026-06-17

### Bug Fixes

- Pin Dockerfile dependencies and verify s6-overlay checksums (#4)

## [0.1.1] — 2026-06-14

### Features

- Log sync startup context (device, conflict strategy, vault) (#3)

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
