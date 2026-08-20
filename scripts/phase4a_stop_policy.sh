#!/usr/bin/env bash
# Phase 4A: stop ACT v1 policy server gracefully. Only touches our own PID.
set -uo pipefail
LOG=/home/cpc/projects/goai-bimaniflow/logs/phase4a
PIDFILE=${LOG}/policy_server.pid
PORT=6061
[ -f "${PIDFILE}" ] || { echo "NOT_RUNNING"; exit 0; }
WPID=$(cat "${PIDFILE}")
CPID=$(pgrep -P "${WPID}" -f 'setup_policy_server.py' || true)
[ -z "${CPID}" ] && CPID=$(pgrep -f 'XPolicyLab/setup_policy_server.py' || true)
if [ -n "${CPID}" ]; then
  kill -INT ${CPID} 2>/dev/null || true
  for i in $(seq 1 10); do kill -0 ${CPID} 2>/dev/null || break; sleep 1; done
  kill -TERM ${CPID} 2>/dev/null || true
  for i in $(seq 1 10); do kill -0 ${CPID} 2>/dev/null || break; sleep 1; done
  if kill -0 ${CPID} 2>/dev/null; then echo "STILL_ALIVE ${CPID} - manual action needed (no SIGKILL by default)"; exit 1; fi
fi
kill -TERM "${WPID}" 2>/dev/null || true
rm -f "${PIDFILE}"
sleep 1
if ss -tln 2>/dev/null | grep -q ":${PORT} "; then echo "PORT_STILL_BOUND"; exit 1; fi
echo "POLICY_SERVER_STOPPED port released"
