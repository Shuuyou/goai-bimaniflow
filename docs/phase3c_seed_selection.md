# Phase 3C-S：最佳 seed 选择

日期：2026-08-18。性质：**single-episode seed screening**（每 seed 仅一个 clean episode），不是三 seed 平均成功率、正式成功率、泛化能力结论或任何统计显著实验。

## 选择过程（按规则）

三 seed 全部 success=false → 进入“全失败”条款：

1. 明确任务进展：**seed_0**（物体接触并被移动）——进展最直接。
2. 正确方向物体移动：无法从视频定量方向（QUALITATIVE），不计入。
3. 成功接触：seed_0 有接触迹象。
4. seed_1 到达目标区但空手（CONTACT_FAILED）；seed_2 仅运动（APPROACH_FAILED）。
5. 稳定性/延迟：三者同级（稳态 P50 ≈23 ms），无区分度。

非编号偏好、非视觉主观、无 ensemble、未修改 checkpoint。

## 结论

- **BEST_ACT_PUSH_T_SEED=0**
- **BEST_SEED_CONFIDENCE=MEDIUM**
- 证据：三 seed 中唯一出现“接触 + 物体位移”任务进展；success 三者皆为 false，区分度有限，故置信度 MEDIUM。
- 本地 `policy_last.ckpt` symlink 指向 `policy_epoch_6000_seed_0.ckpt`（sha256 d41ea255207ceea13b7aa1707d073aae7c38d1b826b5f08b0d82588ad3c41b1a）。
