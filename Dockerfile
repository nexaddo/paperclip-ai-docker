# syntax=docker/dockerfile:1

ARG PAPERCLIP_VERSION=2026.325.0

# ---------------------------------------------------------------------------
# Build stage — install paperclipai at the pinned version
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS builder

ARG PAPERCLIP_VERSION

WORKDIR /app

RUN npm install --global paperclipai@${PAPERCLIP_VERSION}

# ---------------------------------------------------------------------------
# Runtime stage
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim

ARG PAPERCLIP_VERSION
LABEL org.opencontainers.image.title="paperclip-ai"
LABEL org.opencontainers.image.description="Self-hosted PaperclipAI server"
LABEL org.opencontainers.image.source="https://github.com/nexaddo/paperclip-ai-docker"
LABEL org.opencontainers.image.version="${PAPERCLIP_VERSION}"

# Copy global node_modules + bin from builder
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/paperclipai /usr/local/bin/paperclipai

# Data volume — all persistent state lives here
VOLUME ["/data"]

# Paperclip server port
EXPOSE 3100

# Environment defaults — override at runtime
ENV NODE_ENV=production

# Pass secrets via env vars at runtime:
#   ANTHROPIC_API_KEY, GITHUB_TOKEN, etc.

ENTRYPOINT ["paperclipai", "onboard"]
