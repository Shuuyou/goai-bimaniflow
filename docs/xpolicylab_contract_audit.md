# XPolicyLab 协议审计（静态）

子模块：XPolicyLab @ `432f82b1758c5b1202e42a3dfe014546dbc50871`（RoboDojo 锁定）。

## policy 目录（42 个 adapter + demo_policy）

A1, Abot_M0, ACT, AHA_WAM, Being_H05, demo_policy, Dexbotic_DM0, Dexora_1B, DP, DreamZero, EventVLA, FastWAM, G05, GalaxeaVLA, GigaWorldPolicy, GO1, GR00T_N17, H_RDT, Hy_Embodied_05_VLA, InternVLA_A1, InternVLA_A1_5, LDA_1B, LingBot_VA, LingBot_VLA, Mem_0, MolmoACT2, OpenVLA_OFT, Pi_0, Pi_05, Pi_0_Fast, RDT_1B, RISE, SmolVLA, Spatial_Forcing, Spirit_v15, starVLA, TinyVLA, Xiaomi_Robotics_0, Xiaomi_Robotics_1, X_VLA, X_WAM 等。

## 服务入口与启动

- 入口：`python -m client_server.ws` → `model_server.py:main()`，参数 `--config-path deploy.yml [--host --port]`。
- 加载：按 `policy_name` 动态 `import XPolicyLab.policy.<name>.model`，取 `Model` 类以 deploy.yml 构造。
- deploy.yml 字段：policy_name/protocol/host/port/bench_name/task_name/ckpt_name/env_cfg_type/seed/action_type/gpu_id/eval_batch。

## WebSocket 协议（client_server/ws/）

- 传输：`websockets` asyncio server；`max_size=None`，`compression=None`。
- 帧：msgpack envelope（Frame：message_type/request_id/evaluation_id/action_case_id/trial_id/repeat_index/step/payload）。
- 消息类型：HELLO/HELLO_ACK、PREPARE_CASE(_ACK)、RESET/RESET_RESULT、CALL/CALL_RESULT、INFER/INFER_RESULT、TRIAL_END(_ACK)、HEARTBEAT(_ACK)、CLOSE、ERROR。
- keepalive：ping_interval=20s、ping_timeout=20s。
- 可靠性：response cache（256 条）+ 相同 request_id 重试重放；in-flight 去重；server_instance_id 防止重连到不同进程。
- 背压：单连接最多 128 个 in-flight；关闭时 drain 上限 30s。
- 模型串行化：`_model_lock` 互斥；同步方法经 `asyncio.to_thread`；JPEG 解码放线程。
- INFER 路径：`update_obs(obs)`+`get_action()` 成对（同一线程），或 `infer(observation)`；返回 `{actions, latency_ms}`。
- CALL 路径：通用 `func_name` 分发（禁止 `_` 开头）。

## Model 接口（model_template.py）

`update_obs(obs)` / `update_obs_batch(obs_list)` / `get_action()` / `get_action_batch(env_idx_list=None)` / `reset()` / `prepare_case(case_meta)` / `on_trial_end(result)`。

## 动作契约

- `action_type ∈ {ee, joint}`；双臂键：joint → `left/right_arm_joint_state`（各 arm_dim 维）+ `left/right_ee_joint_state`（夹爪）；ee → `left/right_ee_pose`（7 维）+ 夹爪键。
- GOAI 本体 dual_x5：arm_dim [6,6]，ee_dim [1,1] → joint 动作 14 维。
- `get_action` 返回 action_dict 列表（action chunk）。

## 客户端

- 独立 loop 线程；单 outstanding 请求；connect/handshake/request_timeout 等参数默认 None（无应用层超时）——正式评测超时以赛事规则为准（UNKNOWN）。
- 断线重连：相同 request_id 立即重试一次，服务端缓存重放。

## 状态隔离与 reset

单连接即单评测会话；RESET 调 `model.reset()` 无参；服务端模型全局互斥 → 一个 server 进程同时只安全服务一个模型实例的串行请求。

## 正式赛事仍未知

单步/平均超时、并发连接数、最大消息体、是否要求 wss、断线容忍策略、多端点语义——见 goai_submission_contract.md UNKNOWN。
