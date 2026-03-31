# syntax=docker/dockerfile:1

ARG PAPERCLIP_VERSION=2026.325.0

FROM node:22-bookworm-slim

ARG PAPERCLIP_VERSION
LABEL org.opencontainers.image.title="paperclip-ai"
LABEL org.opencontainers.image.description="Self-hosted PaperclipAI server"
LABEL org.opencontainers.image.source="https://github.com/nexaddo/paperclip-ai-docker"
LABEL org.opencontainers.image.version="${PAPERCLIP_VERSION}"

# Install paperclipai in a single stage so the binary and node_modules
# are co-located and Node can resolve dependencies correctly
RUN npm install --global paperclipai@${PAPERCLIP_VERSION}

# Create a non-root user to run Paperclip (embedded Postgres refuses to run as root)
RUN useradd --uid 1000 --create-home --shell /bin/bash paperclip \
    && mkdir -p /data \
    && chown paperclip:paperclip /data

USER paperclip

# Data volume — all persistent state lives here
VOLUME ["/data"]

# Paperclip server port
EXPOSE 3100

# Environment defaults — override at runtime
ENV NODE_ENV=production

# Pass secrets via env vars at runtime:
#   ANTHROPIC_API_KEY, GITHUB_TOKEN, etc.

ENTRYPOINT ["paperclipai", "onboard", "--yes", "--run", "--data-dir", "/data"]
