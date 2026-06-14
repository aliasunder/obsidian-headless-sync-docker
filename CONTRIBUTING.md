# Contributing

Thanks for your interest in this fork of obsidian-headless-sync-docker! It's a
small Docker image, so the contribution loop is simple.

## What this is

A fork of [Belphemur/obsidian-headless-sync-docker](https://github.com/Belphemur/obsidian-headless-sync-docker),
maintained for [vault-cortex](https://github.com/aliasunder/vault-cortex). Its two
main divergences from upstream are a build-time config-dir `chown` and `--device-name`
on the initial Obsidian Sync registration; it also carries its own release/publish
pipeline and CI, with enhanced sync logging planned. See the README "Fork notice"
for details and rationale.

## Prerequisites

- Docker with Buildx (for multi-arch builds), or Podman
- An active [Obsidian Sync](https://obsidian.md/sync) subscription to test end to end

## Build & test

There is no application test suite — the build is the check. Always build before
committing (also required by [AGENTS.md](./AGENTS.md)):

```bash
docker build -t obsidian-headless-sync-docker .

# Multi-arch (what CI builds):
docker buildx build --platform linux/amd64,linux/arm64 -t obsidian-headless-sync-docker .
```

To validate at runtime, run the image with real credentials (see the README
Quick Start) and confirm the container reaches continuous sync.

## Code conventions

Conventions for the Dockerfile, s6-overlay services, and shell scripts live in
[AGENTS.md](./AGENTS.md) — the single source of truth. Key points:

- Shell scripts use the `#!/command/with-contenv sh` shebang and drop privileges
  via `s6-setuidgid obsidian` for every `ob` command
- s6-rc service definitions follow the v3 source format
- All external GitHub Actions are pinned to full commit SHAs with `# vX.Y.Z` comments

## Pull request process

1. **Branch from `main`** with a descriptive prefix (`feat/`, `fix/`, `docs/`,
   `ci/`, `chore/`)
2. **Keep PRs focused** — one logical change per PR
3. **Build the image** and confirm it succeeds before pushing
4. **Fill out the PR template**
5. **Required checks must pass** — `CI` builds the image for amd64 + arm64, and
   two security scans gate merges: **Gitleaks** (secret detection) and **Trivy**
   (a fixable CRITICAL/HIGH CVE in the branch-built image fails `trivy-pr` and
   blocks the merge; details are in the job log)

## Issues

- **Bug reports** and **feature requests**: use the issue templates
- **Security issues**: see [SECURITY.md](./SECURITY.md) — report privately, not
  as a public issue

## Releases

Releases are cut by the maintainer via the **Manual Release** workflow (Actions
tab → "Manual Release" → choose `patch`/`minor`/`major`). It bumps from the
latest tag, builds and pushes a multi-arch image to GHCR with SLSA provenance,
and creates a GitHub release. There is no cron or merge-to-main publish.

## License

The packaging in this repository is [MIT](./LICENSE). Note that the published
image bundles Obsidian's proprietary `obsidian-headless` CLI (see the README
license note). By contributing, you agree your contributions are licensed under
the MIT License.
