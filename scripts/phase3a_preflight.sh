#!/usr/bin/env bash
# Phase 3A preflight: freeze checks + resource red lines. Read-only.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROBODOJO_DIR="${ROOT_DIR}/third_party/RoboDojo"

EXPECT_ROBODOJO="36bfcb7c580b149c6e39ed2eb77d60689152e570"
EXPECT_XPOLICYLAB="432f82b1758c5b1202e42a3dfe014546dbc50871"
EXPECT_ISAACLAB="afca7b09d60d8beb9c1cb28b43066499940b969b"
EXPECT_CUROBO="d17b54ce32cba095c0b000c4c58777075d11de0e"

fail() { echo "[PREFLIGHT-FAIL] $*" >&2; exit 1; }

echo "== git freeze =="
head_sha="$(git -C "${ROOT_DIR}" rev-parse HEAD)"; echo "main HEAD: ${head_sha}"
git -C "${ROOT_DIR}" diff --check || fail "git diff --check"
dirty="$(git -C "${ROOT_DIR}" status --short | grep -vE '^\?\?' || true)"
if [ -n "${dirty}" ]; then
  echo "[warn] main worktree has tracked modifications (expected during Phase 3A-R doc/script updates):" >&2
  echo "${dirty}" >&2
fi

rd_sha="$(git -C "${ROBODOJO_DIR}" rev-parse HEAD)"
[ "${rd_sha}" = "${EXPECT_ROBODOJO}" ] || fail "RoboDojo ${rd_sha} != ${EXPECT_ROBODOJO}"
[ -z "$(git -C "${ROBODOJO_DIR}" status --short)" ] || fail "RoboDojo worktree dirty"
xp="$(git -C "${ROBODOJO_DIR}/XPolicyLab" rev-parse HEAD)"
il="$(git -C "${ROBODOJO_DIR}/third_party/IsaacLab" rev-parse HEAD)"
cr="$(git -C "${ROBODOJO_DIR}/third_party/curobo" rev-parse HEAD)"
[ "${xp}" = "${EXPECT_XPOLICYLAB}" ] || fail "XPolicyLab mismatch: ${xp}"
[ "${il}" = "${EXPECT_ISAACLAB}" ] || fail "IsaacLab mismatch: ${il}"
[ "${cr}" = "${EXPECT_CUROBO}" ] || fail "curobo mismatch: ${cr}"
for sub in XPolicyLab third_party/IsaacLab third_party/curobo; do
  [ -z "$(git -C "${ROBODOJO_DIR}/${sub}" status --short)" ] || fail "${sub} worktree dirty"
done
echo "freeze OK: RoboDojo ${rd_sha}"

echo "== disk red lines =="
root_avail_gb="$(df -BG --output=avail / | tail -1 | tr -dc '0-9')"
d_avail_gb="$(df -BG --output=avail /data | tail -1 | tr -dc '0-9')"
echo "root avail: ${root_avail_gb}G ; data avail: ${d_avail_gb}G"
mode="${1:-prebuild}"
case "${mode}" in
  prebuild) [ "${root_avail_gb}" -ge 200 ] || fail "BLOCKED_ROOT_STORAGE_PREBUILD (${root_avail_gb}G < 200G)" ;;
  postbuild) [ "${root_avail_gb}" -ge 150 ] || fail "BLOCKED_ROOT_STORAGE_POSTBUILD (${root_avail_gb}G < 150G)" ;;
  runtime) [ "${root_avail_gb}" -ge 120 ] || fail "BLOCKED_ROOT_STORAGE_RUNTIME (${root_avail_gb}G < 120G)" ;;
esac
[ "${d_avail_gb}" -ge 1000 ] || echo "[warn] /data below 1T planning line: ${d_avail_gb}G"

echo "== gpu gate =="
nvidia-smi --query-gpu=memory.total,memory.used --format=csv,noheader
free_mib="$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | head -1)"
echo "GPU free: ${free_mib} MiB"
if [ "${mode}" = "runtime" ]; then
  # Phase 3A-R rule: stop only when free VRAM is below what the task needs.
  # Isaac Sim single-env headless + demo_policy needs ~8-12 GiB; threshold 12 GiB.
  [ "${free_mib}" -ge 12288 ] || fail "BLOCKED_GPU_MEMORY (${free_mib} MiB < 12 GiB runtime requirement)"
fi
echo "[PREFLIGHT-OK] mode=${mode}"
