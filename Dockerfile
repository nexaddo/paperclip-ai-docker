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
RUN mkdir -p /data/plugins && chown -R node:node /data

# Pre-install plugins into /data/plugins at build time so they are
# available on first boot without any runtime network access.
COPY --chown=node:node plugins/package.json /data/plugins/package.json
RUN cd /data/plugins && npm install --omit=dev && chown -R node:node /data/plugins

# Entrypoint: first boot runs onboard --yes to generate config,
# then patches host to 0.0.0.0 so the server is reachable outside the container.
# Subsequent boots skip onboard and go straight to run.
COPY --chown=node:node docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER node

# Data volume — all persistent state lives here
VOLUME ["/data"]

# Paperclip server port
EXPOSE 3100

# Environment defaults — override at runtime
ENV NODE_ENV=production

ENTRYPOINT ["docker-entrypoint.sh"]
