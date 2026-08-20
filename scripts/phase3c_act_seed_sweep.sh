# Gate C4/C5 运行脚本：单个 seed 的 server + episode（被人工步骤调用，不自动批量跑）
#!/usr/bin/env bash
# Usage: bash scripts/phase3c_act_seed_sweep.sh <seed:1|2>
set -uo pipefail
SEED="${1:?seed 1|2}"
ROOT=/home/cpc/projects/goai-bimaniflow
RD=${ROOT}/third_party/RoboDojo
CK=/data/goai-bimaniflow/models/ACT/push_T/ckpt/RoboDojo/ACT/act-RoboDojo-push_T/arx_x5-100-joint
LOG=${ROOT}/logs/phase3c
PORT=6061
mkdir -p "${LOG}" /data/goai-bimaniflow/artifacts/phase3c/eval_result

echo "== symlink: $(readlink ${CK}/policy_last.ckpt) -> seed_${SEED}"
ln -sfn "policy_epoch_6000_seed_${SEED}.ckpt" "${CK}/policy_last.ckpt.tmp" && mv -T "${CK}/policy_last.ckpt.tmp" "${CK}/policy_last.ckpt"
echo "readlink now: $(readlink ${CK}/policy_last.ckpt)"
real=$(readlink -f "${CK}/policy_last.ckpt")
sha256sum "${real}" | tee "${LOG}/seed_${SEED}_server_ckpt_sha256.txt"

echo "== start ACT server seed_${SEED} on 127.0.0.1:${PORT}"
nohup conda run --no-capture-output -n bimaniflow-act env \
  PYTHONPATH=${RD} ACT_ACTION_DIM=14 TORCH_HOME=/data/goai-bimaniflow/cache/torch \
  CUDA_VISIBLE_DEVICES=0 PYTHONWARNINGS='ignore::UserWarning' PYTHONUNBUFFERED=1 \
  python ${RD}/XPolicyLab/setup_policy_server.py \
    --config_path ${RD}/XPolicyLab/policy/ACT/deploy.yml \
    --overrides host=127.0.0.1 port=${PORT} bench_name=RoboDojo task_name=push_T \
      ckpt_name=act-RoboDojo-push_T/arx_x5-100-joint ckpt_dir=${CK} \
      env_cfg_type=arx_x5 seed=${SEED} policy_name=ACT action_type=joint action_dim=14 \
  > "${LOG}/seed_${SEED}_policy_server.log" 2>&1 &
SPID=$!
echo "server wrapper pid=${SPID}"
for i in $(seq 1 180); do
  (exec 3<>"/dev/tcp/127.0.0.1/${PORT}") 2>/dev/null && { exec 3>&- 3<&-; break; }
  [ "${i}" = 180 ] && { echo "SERVER_NEVER_UP"; exit 1; }
  sleep 1
done
echo "server up"

echo "== warm-up forward (uncounted) via latency probe =="
conda run --no-capture-output -n bimaniflow-act env PYTHONUNBUFFERED=1 \
  python ${ROOT}/scripts/phase3b_act_latency_probe.py > "${LOG}/seed_${SEED}_warmup_probe.log" 2>&1 \
  && echo "warmup ok" || { echo "WARMUP_FAILED"; kill ${SPID} 2>/dev/null; exit 1; }

echo "== episode: push_T clean, eval-num 1"
docker rm -f bimaniflow-sim-client >/dev/null 2>&1 || true
timeout 5400 docker run --name bimaniflow-sim-client --network host --ipc host --init \
  --gpus '"device=0"' -e NVIDIA_DRIVER_CAPABILITIES=all \
  -v /data/goai-bimaniflow/assets/Assets:/workspace/RoboDojo/Assets:ro \
  -v /data/goai-bimaniflow/assets/Assets:/data/goai-bimaniflow/assets/Assets:ro \
  -v /data/goai-bimaniflow/artifacts/phase3c/eval_result:/workspace/RoboDojo/eval_result \
  -v /data/goai-bimaniflow/cache/isaac/warp:/root/.cache/warp \
  -v /data/goai-bimaniflow/cache/isaac/ov:/root/.cache/ov \
  -v /data/goai-bimaniflow/cache/isaac/ov-data:/root/.local/share/ov \
  -v /data/goai-bimaniflow/cache/isaac/nvidia:/root/.cache/nvidia \
  -v /data/goai-bimaniflow/cache/isaac/nv:/root/.nv \
  -v /data/goai-bimaniflow/logs/kit:/root/miniconda3/envs/RoboDojo/lib/python3.11/site-packages/isaacsim/kit/logs \
  goai-bimaniflow/robodojo:36bfcb7 \
  bash scripts/robodojo.sh client --task push_T --policy-name ACT \
    --policy-host 127.0.0.1 --policy-port ${PORT} \
    --ckpt act-RoboDojo-push_T/arx_x5-100-joint \
    --eval-num 1 --action-type joint --env-gpu 0 \
  > "${LOG}/seed_${SEED}_episode.log" 2>&1
rc=$?
echo "episode exit=${rc}"

echo "== cleanup"
pkill -f 'XPolicyLab/setup_policy_server.py' 2>/dev/null || true
sleep 2
docker rm -f bimaniflow-sim-client >/dev/null 2>&1 || true
ss -tln 2>/dev/null | grep ":${PORT}" && echo "PORT_STILL_BOUND" || echo "port released"
exit ${rc}
