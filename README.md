# paperclip-ai-docker

Docker image wrapper for self-hosting [PaperclipAI](https://github.com/paperclipai/paperclip) on a Synology NAS (or any Docker host).

Published to: `ghcr.io/nexaddo/paperclip-ai-docker`

## Usage

### Quick start

```bash
cp .env.example .env
# Edit .env with your ANTHROPIC_API_KEY
docker compose up -d
```

Paperclip UI will be available at `http://<host-ip>:3100`.

### On Synology

1. Open **Container Manager** → **Project** → **Create**
2. Paste the contents of `docker-compose.yml`
3. Create a shared folder for the `./data` volume (e.g. `/volume1/paperclip/data`), update the volume path in compose accordingly
4. Set environment variables (`ANTHROPIC_API_KEY`, etc.) in the Synology UI or via a `.env` file
5. Start the project

### Agents running locally

This image runs the **Paperclip server and database only** — it does not include Claude CLI or Playwright. Your agents run on your local machine and connect to the server over the network.

Update your local Paperclip client to point at `http://<nas-ip>:3100`.

### Persistent data

All state (database, secrets, config, file storage, backups) is stored in `./data/`. Back this up using Synology Hyper Backup or equivalent.

### Upgrading Paperclip

To upgrade to a new `paperclipai` version:

1. Update `PAPERCLIP_VERSION` in the `Dockerfile`
2. Push to `main` — GitHub Actions rebuilds and pushes the image automatically
3. On the NAS: pull the new image and restart the container

Or trigger manually via **Actions → Build and Push Docker Image → Run workflow** and specify a version.

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes | Anthropic API key for Claude agents |
| `GITHUB_TOKEN` | No | GitHub token if agents use GitHub tools |
| `NODE_ENV` | No | Defaults to `production` |
