#!/usr/bin/env bash
# Phase 4A-Deploy: keep the reverse tunnel ws://<cloud>:8443 -> 127.0.0.1:6061 alive.
# Loop restarts ssh on exit. Logs only timestamps and exit codes.
set -uo pipefail
LOG=/home/cpc/projects/goai-bimaniflow/logs/phase4a/tunnel_watchdog.log
while true; do
  echo "$(date -Is) tunnel starting" >> "$LOG"
  ssh -i ~/.ssh/bimaniflow_deploy -N \
    -R 0.0.0.0:8443:127.0.0.1:6061 \
    -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes \
    -o BatchMode=yes root@<CLOUD_HOST> >> "$LOG" 2>&1
  echo "$(date -Is) tunnel exited rc=$?; restarting in 5s" >> "$LOG"
  sleep 5
done
