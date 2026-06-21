FROM node:26-alpine@sha256:a2dc166a387cc6ca1e62d0c8e265e49ca985d6e60abc9fe6e6c3d6ce8e63f606

ARG S6_OVERLAY_VERSION=3.2.2.0
ARG OBSIDIAN_HEADLESS_VERSION=0.0.12
ARG TARGETARCH

# ---------------------------------------------------------------------------
# Apply Alpine security fixes at build time. Covers the window between an
# Alpine security release and the next node:24-alpine rebuild, so the
# published image doesn't carry already-patched base-package CVEs.
# ---------------------------------------------------------------------------
RUN apk upgrade --no-cache

# ---------------------------------------------------------------------------
# Install s6-overlay (static binaries – works on musl and glibc)
# ---------------------------------------------------------------------------
RUN apk add --no-cache --virtual .s6-deps xz \
    && S6_ARCH="$(case "${TARGETARCH}" in \
         amd64) echo x86_64;; \
         arm64) echo aarch64;; \
         *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1;; \
       esac)" \
    && S6_BASE="https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}" \
    && wget -qO /tmp/s6-overlay-noarch.tar.xz "${S6_BASE}/s6-overlay-noarch.tar.xz" \
    && wget -qO /tmp/s6-overlay-noarch.tar.xz.sha256 "${S6_BASE}/s6-overlay-noarch.tar.xz.sha256" \
    && wget -qO /tmp/s6-overlay-${S6_ARCH}.tar.xz "${S6_BASE}/s6-overlay-${S6_ARCH}.tar.xz" \
    && wget -qO /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256 "${S6_BASE}/s6-overlay-${S6_ARCH}.tar.xz.sha256" \
    && cd /tmp \
    && sha256sum -c s6-overlay-noarch.tar.xz.sha256 \
    && sha256sum -c s6-overlay-${S6_ARCH}.tar.xz.sha256 \
    && tar -C / -Jxpf s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf s6-overlay-${S6_ARCH}.tar.xz \
    && rm -f /tmp/s6-overlay-*.tar.xz /tmp/s6-overlay-*.sha256 \
    && apk del .s6-deps

# ---------------------------------------------------------------------------
# Install obsidian-headless CLI (requires Node 22+)
# ---------------------------------------------------------------------------
RUN npm install -g obsidian-headless@${OBSIDIAN_HEADLESS_VERSION}

# Drop npm/npx/corepack/yarn — only the installed `ob` binary runs at runtime,
# so removing them sheds their bundled dependencies' CVE surface. The
# obsidian-headless package (and its deps) under node_modules is kept.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
    /opt/yarn* /usr/local/bin/yarn /usr/local/bin/yarnpkg

# ---------------------------------------------------------------------------
# Runtime deps: shadow provides usermod/groupmod for PUID/PGID support
# ---------------------------------------------------------------------------
RUN apk add --no-cache shadow

# ---------------------------------------------------------------------------
# Create default non-root user (UID/GID adjustable at runtime via PUID/PGID)
# node:*-alpine ships a 'node' user/group at UID/GID 1000 — remove it first
# ---------------------------------------------------------------------------
RUN deluser --remove-home node || true; \
    delgroup node || true; \
    addgroup -g 1000 obsidian \
    && adduser -u 1000 -G obsidian -h /home/obsidian -s /bin/sh -D obsidian \
    && mkdir -p /vault /home/obsidian/.config \
    && chown obsidian:obsidian /vault /home/obsidian/.config

# ---------------------------------------------------------------------------
# Copy s6-overlay service definitions, init scripts, and helper
# ---------------------------------------------------------------------------
COPY rootfs/ /
COPY get-token.sh /usr/local/bin/get-token
RUN chmod +x /usr/local/bin/get-token \
    && find /etc/s6-overlay/scripts -type f -exec chmod +x {} + \
    && chmod +x /etc/s6-overlay/s6-rc.d/svc-obsidian-sync/run

# ---------------------------------------------------------------------------
# OCI image metadata. org.opencontainers.image.source links the published GHCR
# package to this repository (same approach as vault-cortex's vault-mcp image);
# manual_release.yml also sets these as index annotations so the multi-arch
# package page picks them up.
# ---------------------------------------------------------------------------
LABEL org.opencontainers.image.title="obsidian-headless-sync-docker" \
      org.opencontainers.image.description="Headless Obsidian Sync in Docker (fork) — build-time config chown + DEVICE_NAME on initial registration." \
      org.opencontainers.image.source="https://github.com/aliasunder/obsidian-headless-sync-docker" \
      org.opencontainers.image.licenses="MIT"

# ---------------------------------------------------------------------------
# Volumes: vault data + user config persistence (login state, etc.)
# ---------------------------------------------------------------------------
VOLUME ["/vault", "/home/obsidian/.config"]

# s6-overlay: stop container if any init oneshot fails
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV HOME=/home/obsidian

ENTRYPOINT ["/init"]
