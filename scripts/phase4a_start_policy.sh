#!/usr/bin/env bash
# Phase 4A: start ACT v1 policy server on 127.0.0.1:6061 (loopback only).
set -euo pipefail
ROOT=/home/cpc/projects/goai-bimaniflow
RD=${ROOT}/third_party/RoboDojo
CK=/data/goai-bimaniflow/models/ACT/push_T/ckpt/RoboDojo/ACT/act-RoboDojo-push_T/arx_x5-100-joint
LOG=${ROOT}/logs/phase4a
PIDFILE=${LOG}/policy_server.pid
PORT=6061
mkdir -p "${LOG}"

# freeze checks
want_sha=d41ea255207ceea13b7aa1707d073aae7c38d1b826b5f08b0d82588ad3c41b1a
real=$(readlink -f "${CK}/policy_last.ckpt")
actual=$(sha256sum "${real}" | awk '{print $1}')
[ "${actual}" = "${want_sha}" ] || { echo "CHECKPOINT_MISMATCH ${actual}"; exit 1; }
echo "checkpoint: $(basename "${real}") sha256 OK"

# port conflict policy: refuse, never steal
if ss -tln 2>/dev/null | grep -q ":${PORT} "; then
  echo "PORT_${PORT}_BUSY"; exit 1
fi
# stale pidfile policy
if [ -f "${PIDFILE}" ]; then
  old=$(cat "${PIDFILE}")
  if ps -p "${old}" -o cmd= 2>/dev/null | grep -q setup_policy_server; then
    echo "ALREADY_RUNNING pid=${old}"; exit 0
  fi
  rm -f "${PIDFILE}"
fi

# rotate oversized log (keep 3)
if [ -f "${LOG}/policy_server.log" ] && [ "$(stat -c%s "${LOG}/policy_server.log")" -gt 209715200 ]; then
  mv -f "${LOG}/policy_server.log.2" "${LOG}/policy_server.log.3" 2>/dev/null || true
  mv -f "${LOG}/policy_server.log.1" "${LOG}/policy_server.log.2" 2>/dev/null || true
  mv "${LOG}/policy_server.log" "${LOG}/policy_server.log.1"
fi

cd "${RD}"
nohup conda run --no-capture-output -n bimaniflow-act env \
  PYTHONPATH=${RD} ACT_ACTION_DIM=14 TORCH_HOME=/data/goai-bimaniflow/cache/torch \
  CUDA_VISIBLE_DEVICES=0 PYTHONWARNINGS='ignore::UserWarning' PYTHONUNBUFFERED=1 \
  python XPolicyLab/setup_policy_server.py \
    --config_path XPolicyLab/policy/ACT/deploy.yml \
    --overrides host=127.0.0.1 port=${PORT} bench_name=RoboDojo task_name=push_T \
      ckpt_name=act-RoboDojo-push_T/arx_x5-100-joint ckpt_dir=${CK} \
      env_cfg_type=arx_x5 seed=0 policy_name=ACT action_type=joint action_dim=14 \
  >> "${LOG}/policy_server.log" 2>&1 &
echo $! > "${PIDFILE}"
for i in $(seq 1 180); do
  if (exec 3<>"/dev/tcp/127.0.0.1/${PORT}") 2>/dev/null; then exec 3>&- 3<&-; break; fi
  [ "${i}" = 180 ] && { echo "SERVER_NEVER_UP"; exit 1; }
  sleep 1
done
echo "POLICY_SERVER_UP pid=$(cat ${PIDFILE}) port=${PORT}"
