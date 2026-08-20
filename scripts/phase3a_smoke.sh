#!/usr/bin/env bash
# Phase 3A smoke: demo_policy protocol test (J) + single-task single-episode run (K).
# Loopback only; no training; no public exposure. Logs -> logs/phase3a/.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${ROOT_DIR}/logs/phase3a"
mkdir -p "${LOG_DIR}"

IMAGE="goai-bimaniflow/robodojo:36bfcb7"
TASK="${BIMANIFLOW_TASK:-push_T}"
ACTION_TYPE="${BIMANIFLOW_ACTION_TYPE:-joint}"
PORT="${BIMANIFLOW_POLICY_PORT:-6060}"
GOAI_DATA_ROOT="${GOAI_DATA_ROOT:-/data/goai-bimaniflow/assets}"
ARTIFACT_ROOT="${BIMANIFLOW_ARTIFACT_ROOT:-/data/goai-bimaniflow/artifacts}"
CACHE_ROOT="${BIMANIFLOW_CACHE_ROOT:-/data/goai-bimaniflow/cache}"
SERVER_NAME="bimaniflow-policy-server"
SIM_NAME="bimaniflow-sim-client"
STEP="${1:-all}"   # protocol | sim | all

mkdir -p "${ARTIFACT_ROOT}/phase3a/eval_result" "${CACHE_ROOT}/warp" "${CACHE_ROOT}/ov" "${CACHE_ROOT}/ov-data" "${CACHE_ROOT}/nvidia" "${CACHE_ROOT}/nv"

cleanup() {
  docker rm -f "${SIM_NAME}" "${SERVER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

bash "${ROOT_DIR}/scripts/phase3a_preflight.sh" runtime || exit 1

echo "== start demo_policy server (127.0.0.1:${PORT}) =="
docker rm -f "${SERVER_NAME}" >/dev/null 2>&1 || true
docker run -d --name "${SERVER_NAME}" --network host --ipc host --init \
  -e PYTHONWARNINGS=ignore::UserWarning \
  "${IMAGE}" \
  python XPolicyLab/setup_policy_server.py \
    --config_path XPolicyLab/policy/demo_policy/deploy.yml \
    --overrides host=127.0.0.1 port="${PORT}" bench_name=RoboDojo task_name="${TASK}" \
      ckpt_name=smoke env_cfg_type=arx_x5 seed=0 policy_name=demo_policy action_type="${ACTION_TYPE}" \
  > "${LOG_DIR}/policy_server_cid.log" 2>&1 || { echo "server start failed"; exit 1; }

# wait for the port (max 120 s)
for i in $(seq 1 120); do
  if (exec 3<>"/dev/tcp/127.0.0.1/${PORT}") 2>/dev/null; then exec 3>&- 3<&-; break; fi
  [ "${i}" = 120 ] && { echo "policy server port never came up"; docker logs "${SERVER_NAME}" > "${LOG_DIR}/policy_server.log" 2>&1; exit 1; }
  sleep 1
done
echo "policy server is up"

if [ "${STEP}" = "protocol" ] || [ "${STEP}" = "all" ]; then
  echo "== step J: official debug client protocol test =="
  timeout 600 docker run --rm --name bimaniflow-debug-client --network host --ipc host --init \
    "${IMAGE}" \
    python XPolicyLab/debug_env_client.py \
      --bench_name RoboDojo --task_name "${TASK}" --env_cfg_type arx_x5 \
      --policy_name demo_policy --protocol ws --host 127.0.0.1 --port "${PORT}" \
      --evaluation_id phase3a-debug --trial_id debug-trial-0 --eval_episode_num 1 \
    > "${LOG_DIR}/debug_client.log" 2>&1
  rc=$?
  echo "debug client exit: ${rc}"
  [ "${rc}" -eq 0 ] || { echo "STEP J FAILED (see ${LOG_DIR}/debug_client.log)"; docker logs "${SERVER_NAME}" > "${LOG_DIR}/policy_server.log" 2>&1; exit 1; }
fi

if [ "${STEP}" = "sim" ] || [ "${STEP}" = "all" ]; then
  echo "== step K: single task (${TASK}) single episode in Isaac Sim =="
  docker rm -f "${SIM_NAME}" >/dev/null 2>&1 || true
  timeout 1800 docker run --name "${SIM_NAME}" --network host --ipc host --init \
    --gpus '"device=0"' \
    -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all \
    -v "${GOAI_DATA_ROOT}/Assets:/workspace/RoboDojo/Assets:ro" \
    -v "${GOAI_DATA_ROOT}/Assets:${GOAI_DATA_ROOT}/Assets:ro" \
    -v "${ARTIFACT_ROOT}/phase3a/eval_result:/workspace/RoboDojo/eval_result" \
    -v "${CACHE_ROOT}/warp:/root/.cache/warp" \
    -v "${CACHE_ROOT}/ov:/root/.cache/ov" \
    -v "${CACHE_ROOT}/ov-data:/root/.local/share/ov" \
    -v "${CACHE_ROOT}/nvidia:/root/.cache/nvidia" \
    -v "${CACHE_ROOT}/nv:/root/.nv" \
    "${IMAGE}" \
    bash scripts/robodojo.sh client \
      --task "${TASK}" --policy-name demo_policy \
      --policy-host 127.0.0.1 --policy-port "${PORT}" \
      --ckpt smoke --eval-num 1 --action-type "${ACTION_TYPE}" --env-gpu 0 \
    > "${LOG_DIR}/sim_client.log" 2>&1
  rc=$?
  echo "sim client exit: ${rc}"
  docker logs "${SERVER_NAME}" > "${LOG_DIR}/policy_server.log" 2>&1 || true
  [ "${rc}" -eq 0 ] || { echo "STEP K FAILED rc=${rc} (see ${LOG_DIR}/sim_client.log)"; exit 1; }
fi

docker logs "${SERVER_NAME}" > "${LOG_DIR}/policy_server.log" 2>&1 || true
echo "[SMOKE-OK] step=${STEP}"
