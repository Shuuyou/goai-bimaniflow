# Phase 3C-S：push_T 三 seed 失败诊断（single-episode seed screening）

证据边界：官方评测只落盘结果 JSON 与三路视频（_stream 为空），**关节位移、动作逐维统计、物体精确位姿均无日志记录** → 以下涉及动作量与物体状态的内容一律为 **QUALITATIVE（基于视频帧）**，不从像素估算精确物理距离。观测/推理次数由协议行为确证：temporal_agg 下 query_frequency=1，600 步 = 600 次 update_obs + get_action；探针已验证动作键、dtype、有限性。

## 各 seed 诊断

### seed_0（Phase 3B 结果，2026-08-17_07-18-51）
- 视频：双臂持续运动；左腕相机帧 300 显示夹爪位于红色 T 块上方；head 帧 599 中 T 块已不在初始位置，目标垫为空。
- 判定：发生接近与接触，物体被移动但未进入目标位姿。
- 失败分类：**OBJECT_MOVED_WRONG_DIRECTION**（QUALITATIVE）。

### seed_1（2026-08-17_10-27-58）
- 视频：右臂大幅运动；左腕相机帧 300 显示夹爪正对灰色目标垫中央（到达目标区），但红色 T 块未被携带；head 帧 599 目标垫为空。
- 判定：到达目标区域成功，但物体未被搬运——接近阶段有效，接触/抓取阶段失败。
- 失败分类：**CONTACT_FAILED**（QUALITATIVE）。

### seed_2（2026-08-18_02-56-36）
- 视频：右臂在桌面右侧运动；head 帧 599 中红色 T 块仍在初始位姿附近，目标垫为空。
- 判定：有运动但未对物体产生有效作用。
- 失败分类：**APPROACH_FAILED**（QUALITATIVE）。

## 统一健康度表

| 项 | seed_0 | seed_1 | seed_2 |
|---|---|---|---|
| 观测数 / 推理次数 | 600 / 600 | 600 / 600 | 600 / 600 |
| episode 完成 | 600/600 | 600/600 | 600/600 |
| 动作 NaN/Inf | 无（探针实证） | 无 | 无 |
| 机器人实际运动 | 明显（视频） | 明显（视频） | 明显（视频） |
| 关节位移等定量 | NOT_LOGGED | NOT_LOGGED | NOT_LOGGED |
| 物体位移 | 有（离开原位） | 未见（未被携带） | 无 |
| 到达目标区 | 否 | **是（空手）** | 否 |
| 接触 | 有迹象 | 未见有效接触 | 未见 |
| success | false | false | false |

## 排除项

- ACTION_SCHEMA_SUSPECT / GRIPPER_SEMANTIC_SUSPECT：无证据——动作被环境接受、机器人产生与动作一致的实际位移。
- ENVIRONMENT_OR_ASSET_FAILURE：无证据。
- NO_MEANINGFUL_MOTION：不成立。

## 结论

至少两个 seed（0、1）出现明确任务进展迹象 → 不触发 BLOCKED_ACT_POLICY_VALIDITY，允许进入 random 阶段。
