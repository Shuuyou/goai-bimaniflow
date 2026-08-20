#!/usr/bin/env python
"""Phase 4A healthcheck: official WsModelClient HELLO/RESET/INFER/CLOSE.

Exit 0 = healthy. Prints one line of latency. No observation payloads are logged.
"""
import sys, time
sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo/XPolicyLab")
sys.path.insert(0, "/home/cpc/projects/goai-bimaniflow/third_party/RoboDojo")
from debug_env_client import TestEnv  # official debug client env (official obs schema)

cfg = dict(
    bench_name="RoboDojo", task_name="push_T", env_cfg_type="arx_x5",
    policy_name="ACT", protocol="ws", host="127.0.0.1", port=6061,
    policy_server_url=None, evaluation_id="phase4a-health",
    action_case_id=None, trial_id="health-0", repeat_index=None,
    eval_episode_num=1, eval_batch=False, obs_encoded=False,
)
try:
    env = TestEnv(cfg)
    mc = env.model_client  # HELLO at connect
    t0 = time.time()
    mc.call(func_name="reset")
    obs = env.get_obs()
    mc.call(func_name="update_obs", obs=obs)
    t1 = time.time()
    actions = mc.call(func_name="get_action")
    lat = (time.time() - t1) * 1000
    keys = sorted(actions[0].keys()) if actions else []
    ok = bool(actions) and "left_arm_joint_state" in keys
    close = getattr(mc, "close", None)
    if callable(close):
        close()
    print(f"HEALTHCHECK {'OK' if ok else 'BAD_ACTION'} infer_ms={lat:.1f}")
    sys.exit(0 if ok else 1)
except Exception as e:
    print(f"HEALTHCHECK FAIL {type(e).__name__}: {e}")
    sys.exit(1)
