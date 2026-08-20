#!/usr/bin/env python
"""Phase 4A local regression: 100 consecutive INFER calls against the frozen
ACT v1 server, using the OFFICIAL debug client TestEnv/WsModelClient.
Protocol sequence: connect(HELLO) -> PREPARE_CASE(via CALL prepare_case) ->
RESET -> 100x(update_obs+get_action) -> RESET -> CLOSE.
No sim, no public bind, no observation logging.
"""
import sys, time
import numpy as np

sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo/XPolicyLab")
sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo")
from debug_env_client import TestEnv

cfg = dict(
    bench_name="RoboDojo", task_name="push_T", env_cfg_type="arx_x5",
    policy_name="ACT", protocol="ws", host="127.0.0.1", port=6061,
    policy_server_url=None, evaluation_id="phase4a-regression",
    action_case_id="case-0", trial_id="regression-0", repeat_index=0,
    eval_episode_num=1, eval_batch=False, obs_encoded=False,
)
env = TestEnv(cfg)
mc = env.model_client  # HELLO at connect
print("CONNECTED", flush=True)

try:
    mc.call(func_name="prepare_case")
    print("PREPARE_CASE_OK", flush=True)
except Exception as e:
    print("PREPARE_CASE_FAIL", type(e).__name__, e, flush=True)
    sys.exit(2)
t0 = time.time(); mc.call(func_name="reset"); print("RESET_MS", round((time.time()-t0)*1000,1), flush=True)

lat = []
obs = env.get_obs()
first_shapes = None
for i in range(100):
    t1 = time.time()
    mc.call(func_name="update_obs", obs=obs)
    actions = mc.call(func_name="get_action")
    lat.append((time.time() - t1) * 1000)
    a = np.asarray(actions[0]["left_arm_joint_state"])
    if first_shapes is None:
        first_shapes = (sorted(actions[0].keys()), a.shape, str(a.dtype))
    if not np.isfinite(a).all():
        print("NAN_OR_INF at iter", i); sys.exit(2)
    if not actions or len(actions) != 1:
        print("BAD_CHUNK at iter", i); sys.exit(2)
print("ACTION_CONTRACT", first_shapes, flush=True)
print("INFER_100_OK", flush=True)

t0 = time.time(); mc.call(func_name="reset"); print("RESET2_MS", round((time.time()-t0)*1000,1), flush=True)

close = getattr(mc, "close", None)
if callable(close):
    close()
print("CLOSED", flush=True)

arr = np.array(lat)
print("N", len(arr))
print("FIRST_MS", round(arr[0], 1))
print("MEAN_MS", round(arr.mean(), 1))
print("P50_MS", round(np.percentile(arr, 50), 1))
print("P95_MS", round(np.percentile(arr, 95), 1))
print("P99_MS", round(np.percentile(arr, 99), 1))
print("MAX_MS", round(arr.max(), 1))
print("REGRESSION_DONE", flush=True)
