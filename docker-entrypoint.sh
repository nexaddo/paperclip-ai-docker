#!/bin/sh
set -e

CONFIG="/data/instances/default/config.json"

if [ ! -f "$CONFIG" ]; then
  echo "[entrypoint] First boot: running onboard --yes to generate config..."
  paperclipai onboard --yes --data-dir /data

  echo "[entrypoint] Patching server host to 0.0.0.0 for container networking..."
  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
    cfg.server.host = '0.0.0.0';
    cfg.server.exposure = 'public';
    fs.writeFileSync('$CONFIG', JSON.stringify(cfg, null, 2));
    console.log('[entrypoint] Config patched: host=0.0.0.0, exposure=public');
  "
else
  echo "[entrypoint] Config exists, skipping onboard."
fi

echo "[entrypoint] Starting Paperclip server..."
exec paperclipai run --data-dir /data
