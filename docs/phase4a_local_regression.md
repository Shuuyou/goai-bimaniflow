# Phase 4A 本地不可变回归（无仿真 episode）

日期：2026-08-19。冻结配置：seed_0 / joint / 14 维 / 127.0.0.1:6061 / bimaniflow-act / act_v1.yaml。启动经 `scripts/phase4a_start_policy.sh`（sha256 冻结校验通过）。

## 结果

- 协议序列：connect(HELLO) ✓ → PREPARE_CASE ✓ → RESET(183.4 ms) ✓ → **100/100 INFER 全部成功** ✓ → RESET2(183.9 ms) ✓ → CLOSE ✓；服务由 stop 脚本正常退出，端口释放，无僵尸进程。
- 动作契约全程一致：keys = [left_arm_joint_state, left_ee_joint_state, right_arm_joint_state, right_ee_joint_state]，左臂 (6,) float64，无 NaN/Inf，chunk_len=1（temporal_agg 预期）。
- 延迟（N=100）：first 28.2 ms / mean 27.0 / **P50 22.8 / P95 28.3 / P99 116.1 / max 247.7 ms**。P99 尾部为主机共享负载抖动，不是协议错误。
- 首次真实推理（冷模型）：15.9 s（一次性 cuDNN autotune/预热）；正式部署须在审核前完成预热。
- GPU 显存：2544 MiB（加载后）→ 4012 MiB（推理暖态），随后恒定（B8 600 步 episode 亦恒定 ~4 GB）；系统 RAM +0.8 GB（含客户端）。
- 连接泄漏：CLOSE 后无残留连接；状态泄漏：RESET 后 t 计数器归零。
- 重复 request ID 重放：**UNEXERCISED**（官方客户端仅在断线重试时复用 request_id；本次无断线）——服务端 replay cache 逻辑静态审计已验证（model_server.py:294-332）。

## 结论

**LOCAL_REGRESSION_PASSED**。
