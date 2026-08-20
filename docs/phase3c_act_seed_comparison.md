# Phase 3C-S：ACT 三 seed 一致性核验

日期：2026-08-17/18。所有操作为只读分析 + 官方 adapter 严格加载。

## 文件与完整性

| 文件 | 大小 | sha256 前缀（=官方 LFS oid） |
|---|---|---|
| policy_epoch_6000_seed_0.ckpt | 335,912,094 B | d41ea255207ceea1 ✓ |
| policy_epoch_6000_seed_1.ckpt | 335,912,094 B | 070e6ccacf2e74cc ✓ |
| policy_epoch_6000_seed_2.ckpt | 335,912,094 B | db3017ca905bc846 ✓ |
| dataset_stats.pkl | 44,209 B | 642f47f1f4052a9e ✓（三 seed 共用同一文件，未改动） |

## 结构核验（torch.load map_location=cpu，只读）

- 三个 checkpoint 均为**纯 state_dict**（无 config/epoch/seed/optimizer 元数据）。
- state_dict keys：**344，三者完全一致（STRUCTURE_IDENTICAL=True）**。
- 张量元素总数：83,943,311 ×3；无 NaN/Inf。
- 关键形状：pos_table [1,52,512]（与 chunk 50 一致），in_proj 1536×512（hidden 512）——与 deploy.yml 一致。
- policy class：ACT（CVAE）；action/state dim 14；相机 [cam_head, cam_right_wrist, cam_left_wrist]。
- 结论：结构完全一致，无 BLOCKED_ACT_SEED_STRUCTURE_MISMATCH。

## 独立严格加载（Gate C2）

| seed | 实际加载文件（readlink 核验） | sha256 | 加载时间 | 首次合成 forward | 峰值显存 | 输出 |
|---|---|---|---|---|---|---|
| seed_1 | policy_epoch_6000_seed_1.ckpt | 070e6cca…e2e96 ✓ | 50.8s | 12.2s | 1990 MiB | (1,14) float64 finite |
| seed_2 | policy_epoch_6000_seed_2.ckpt | db3017ca…f0f46 ✓ | 1.6s | 0.23s | 1990 MiB | (1,14) float64 finite |

- 均 strict（官方 load_state_dict 默认）；无 missing/unexpected keys。
- symlink 原子切换（ln tmp + mv -T），切换前后 readlink 已记录；官方 ckpt 与 stats 未修改。
- 合成 forward 仅形状验证，不构成策略表现证据。
