# Gate B1：ACT 上游契约静态审计

来源：RoboDojo 锁定 XPolicyLab @ 432f82b，policy/ACT。日期：2026-08-17。

## 环境与安装

1. **Python**：install.sh 未固定 Python；conda_env.yaml 是上游 ACT 遗留（py3.9/torch2.0/cu118），**安装实际以 install.sh 为准**（pip 级）。
2. **PyTorch/CUDA**：install.sh 装 `torch==2.4.1 torchvision`（默认 PyPI wheel = cu121）。**cu121 不支持 sm_120（RTX 5090）**——处理方案见 environment plan。
3. **websockets**：XPolicyLab pyproject 要求 >=14.0（policy server 运行必需）。
4. **checkpoint 解析规则**：deploy.yml `ckpt_dir: null`；setup_eval_policy_server.sh 按顺序解析：绝对路径 → `policy/ACT/checkpoints/<ckpt_name>` → `policy/ACT/<ckpt_name>`，随后以 `ckpt_dir=` override 传入。
5. **checkpoint 形态**：目录。
6. **必需文件清单**（act_policy.py:139-153，缺失即 FileNotFoundError）：`dataset_stats.pkl` + `policy_last.ckpt`。
7. **checkpoint 文件名**：加载器硬编码 `policy_last.ckpt`；训练侧写 `policy_epoch_<N>_seed_<S>.ckpt`。
8. **normalization stats**：`dataset_stats.pkl`（qpos_mean/std、action_mean/std）。
9. **policy config**：无独立配置文件；配置来自 deploy.yml + setup 脚本注入的 `action_dim`（ACT_ACTION_DIM 由 env_cfg_type 推导：dual_x5 joint → 14）。
10. **optimizer state**：加载用 `load_state_dict`（policy_only）。
11. **tokenizer/语言模型**：不需要。
12. **三路相机**：是，`camera_names: [cam_head, cam_right_wrist, cam_left_wrist]`。
13. **相机 key**：与 RoboDojo 观测一致（K1 已实证）。
14. **机器人状态 key（obs, joint 模式）**：state.left_arm_joint_state(6) + left_ee_joint_state(1) + right_arm_joint_state(6) + right_ee_joint_state(1)，pack 顺序 [arm0, ee0, arm1, ee1]。
15. **动作类型**：由 deploy/CLI `action_type` 决定；checkpoint 目录名含 `joint`。
16. **action dimension**：joint → 6+6+1+1 = **14**。
17. **夹爪位置**：每臂 arm 后紧跟 ee（索引 6 与 13）。
18. **动作归一化**：是（dataset_stats.pkl z-score；推理时 post_process 反归一化）。
19. **action chunk**：`chunk_size=50`（num_queries=50）。
20. **temporal aggregation**：`temporal_agg: true`，k=0.01，query_frequency=1。
21. **推理返回频率**：每步返回 1 个动作（raw_action [1,14]）。
22. **checkpoint embodiment**：目录名 `arx_x5-100-joint`。
23. **arx_x5 vs dual_x5 vs GOAI**：核验证据链——`env_cfg/arx_x5.yml` → `config.robot: dual_x5`；`_robot_info.json` → dual_x5 = arm[6,6]+ee[1,1]；GOAI-2026 HDF5 路径 `data/hdf5/<task>/arx_x5/`；布局 `Assets/Eval_Layout/RoboDojo/arx_x5/`。**结论：arx_x5 是 env_cfg/数据命名，本体为 dual_x5，VERIFIED（非目录名臆断）**。
24. **ACT adapter 直接连接 dual_x5 obs**：是。
25. **字段名转换**：无。
26. **动作维度转换**：无（14 维直通）。
27. **本地补丁**：需要一项非上游修改的本地安排——官方 ckpt 内含 `policy_epoch_6000_seed_{0,1,2}.ckpt`，而加载器硬编码 `policy_last.ckpt`；方案：本地符号链接（不动上游、不动官方文件）。
28. **可纯配置完成**：除上述链接外是。

## 协议侧

沿用 XPolicyLab ws server（HELLO/PREPARE_CASE/RESET/CALL/INFER/TRIAL_END/HEARTBEAT/CLOSE），ACT model.py 实现 update_obs/get_action/reset。

## 风险

- R1：install.sh 的 torch 2.4.1(cu121) 不支持 sm_120 → 环境中用已验证的 torch 2.7.0+cu128。
- R2：chunk_size=50/temporal_agg 与 checkpoint 训练配置一致性无法从元数据确认 → Gate B6 严格加载 + 形状校验实证（已通过）。
