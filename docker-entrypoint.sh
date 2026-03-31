#!/bin/sh
set -e

DATA_DIR="/data"
CONFIG="$DATA_DIR/instances/default/config.json"

# On first boot, run onboard to initialize the DB schema, secrets key, and
# base config. Subsequent boots skip this — the run command re-derives config
# from environment variables (PAPERCLIP_DEPLOYMENT_MODE, HOST, PORT, etc.)
# so no manual config patching is needed.
if [ ! -f "$CONFIG" ]; then
  echo "[entrypoint] First boot: running onboard --yes to initialize data dir..."
  paperclipai onboard --yes --data-dir "$DATA_DIR"
else
  echo "[entrypoint] Config exists, skipping onboard."
fi

echo "[entrypoint] Starting Paperclip server..."
exec paperclipai run --data-dir "$DATA_DIR"
