# Baseline 静态筛选（Screening）

日期：2026-08-12。依据：RoboDojo 锁定 XPolicyLab @ 432f82b 中真实存在的 adapter、README、脚本与官方 ckpt 目录（hf://datasets/RoboDojo-Benchmark/RoboDojo/ckpt/RoboDojo/，32 个 policy 目录）。未运行、未下载权重。GOAI 本体为 dual_x5 双臂（arm 6+6, gripper 1+1），数据全为 arx_x5 演示。

## 候选评估

### Tier 0 — 协议链路验证

| 项 | demo_policy |
|---|---|
| adapter | XPolicyLab/policy/demo_policy（model.py/deploy.yml/eval.sh 齐全） |
| 训练/权重 | 无需训练、无权重；输出零/单位四元数动作 |
| 双臂/ee/joint | 单双臂与 ee/joint 全部分支实现 |
| License | 随 XPolicyLab Apache-2.0 |
| 结论 | **进入 shortlist（Tier 0）**：24 配置端到端链路 + Policy Server 协议验证的唯一零风险入口 |

### Tier 1 — 轻量行为克隆

| 项 | ACT | DP |
|---|---|---|
| adapter | policy/ACT（detr/ vendored，train.sh/eval.sh/install.sh 齐全） | policy/DP（diffusion_policy/ vendored） |
| 训练命令 | `bash train.sh RoboDojo cotrain arx_x5 joint 0 0`（README 明示） | 同款接口 |
| 数据管线 | process_data.sh 直接消费 RoboDojo HDF5 | process_data.sh → zarr |
| 官方 ckpt | 有（ckpt/RoboDojo/ACT） | **无** |
| 双臂 | 原生 bimanual（ALOHA 血统） | 由 adapter 数据维度驱动，README 未明示——UNKNOWN |
| 5090 单卡训练 | 可行（ACT 轻量） | 可行（单任务） |
| License | MIT | MIT（上游 diffusion_policy） |
| 工程风险 | 低 | 低-中（无官方 ckpt，必须自训验证） |
| 结论 | **Tier 1 首选** | **Tier 1 备选** |

### Tier 2 — 强开源 VLA/WAM

| 项 | Pi_05 | GR00T_N17 | X_WAM |
|---|---|---|---|
| adapter | policy/Pi_05（openpi vendored，uv 环境） | policy/GR00T_N17（vendored，uv） | policy/X_WAM（vendored，conda 3.10） |
| 官方 ckpt | 有 | 有 | 有 |
| X-Eval 通用榜参考 | Clean 70.7% / Rand 46.0%（VERIFIED_XEVAL_GENERAL，第 1 名） | 不在示例榜 | 榜第 3（overall 38.1） |
| 动作空间 | 由训练配置决定 | README 示例 joint | **仅 ee**（README 明示） |
| 基座权重 | pi05_base | nvidia/GR00T-N1.7-3B | Wan2.2-TI2V-5B + 官方仓库 |
| 参数规模 | ~3B 级 | 3B | WAM + 5B 视频基座 |
| 5090 单卡推理 | 可行 | 可行 | 中-高（显存压力） |
| 5090 单卡训练 | 后训练可行（余量紧张） | 紧张 | 高风险 |
| License | 代码 Apache-2.0；权重 UNKNOWN | 代码 Apache-2.0；权重 NVIDIA Open Model License | 权重许可 UNKNOWN |
| 工程风险 | 中 | 中 | 高（ee-only 锁定、双基座） |
| 结论 | **Tier 2 首选** | 候补 | **Tier 2 备选** |

## Shortlist（≤5）

1. **demo_policy**（Tier 0）— 链路/协议验证。
2. **ACT**（Tier 1 首选）— 完整 HDF5 管线 + 官方 ckpt + 单卡可训。
3. **DP**（Tier 1 备选）— 无官方 ckpt，需自训。
4. **Pi_05**（Tier 2 首选）— 官方 ckpt + 通用榜最强证据 + 单卡推理可行。
5. **X_WAM**（Tier 2 备选）— 官方 ckpt + 跨本体泛化定位；ee-only 与显存为风险。

筛选纪律：未按名气入选；未假设任何模型支持双臂（均以 README 明示或数据维度为准）；未下载任何权重。
