#!/usr/bin/env python
"""Phase 3B ACT latency probe.

Reuses the OFFICIAL XPolicyLab debug client (debug_env_client.TestEnv) for
observation generation and the official WsModelClient transport. No custom
observation schema is created here; only timing instrumentation is added.
"""
import sys, time
import numpy as np

sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo/XPolicyLab")
sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo")

from debug_env_client import TestEnv  # official debug client env

deploy_cfg = dict(
    bench_name="RoboDojo", task_name="push_T", env_cfg_type="arx_x5",
    policy_name="ACT", protocol="ws", host="127.0.0.1", port=6061,
    policy_server_url=None, evaluation_id="phase3b-latency",
    action_case_id=None, trial_id="latency-trial-0", repeat_index=None,
    eval_episode_num=1, eval_batch=False, obs_encoded=False,
)

env = TestEnv(deploy_cfg)
mc = env.model_client

t0 = time.time()
mc.call(func_name="reset")
print("RESET_OK", round(time.time() - t0, 3), flush=True)

lat = []
N = 30
obs = env.get_obs()
for i in range(N):
    t1 = time.time()
    mc.call(func_name="update_obs", obs=obs)
    actions = mc.call(func_name="get_action")
    dt = (time.time() - t1) * 1000.0
    lat.append(dt)
    if i == 0:
        print("FIRST_INFER_MS", round(dt, 1), flush=True)
        a0 = np.asarray(actions[0]["left_arm_joint_state"])
        print("ACTION_SAMPLE", a0.shape, a0.dtype, bool(np.isfinite(a0).all()), flush=True)
        print("ACTION_KEYS", sorted(actions[0].keys()), "chunk_len", len(actions), flush=True)

arr = np.array(lat[1:])  # steady-state excludes first
print("STEADY_N", len(arr))
print("LAT_MEAN_MS", round(arr.mean(), 1))
print("LAT_P50_MS", round(np.percentile(arr, 50), 1))
print("LAT_P95_MS", round(np.percentile(arr, 95), 1))
print("LAT_P99_MS", round(np.percentile(arr, 99), 1))
print("LAT_MAX_MS", round(arr.max(), 1))

mc.call(func_name="reset")
print("RESET2_OK", flush=True)

close = getattr(mc, "close", None)
if callable(close):
    close()
print("PROBE_DONE", flush=True)
