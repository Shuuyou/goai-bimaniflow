# BiManiFlow 项目状态（PROJECT_STATE）

更新日期：2026-08-12。本文件是项目单一事实来源入口；细节分散在各专项文档。

## 1. 项目目标

GOAI 2026 世界人工智能开源大赛 · 具身未来赛道 · 赛题一「通用双臂协同操作挑战赛」：构建可运行、可复现、可评测的双臂策略系统，通过公网 WebSocket Policy Server 接受 X-Eval 正式评测，目标仿真初赛前 10 晋级真机决赛。不保证获奖；一切工作以提高任务成绩、泛化能力、可靠性与证据质量为目标。

## 2. 当前日期 / 3. 截止日期

- 当前：2026-08-12。
- 初赛（评测申请开放）：2026-07-16 至 **2026-08-20**（AOE）；初赛评审 8.21–8.23。来源：xsparkai.com/goai-2026/ 前端 bundle `index-J1Id2EKy.js` 中赛程表（详见 xeval_public_recon.md）。

## 4. 当前服务器角色

单卡 RTX 5090 节点（Baiyang-5090-1）为唯一主节点：Git 主工作区、RoboDojo、XPolicyLab、Docker、Isaac Sim/Lab、数据与资产管理、单卡训练、本地仿真自测、Policy Server、checkpoint 与结果归档。

## 5. 4090D 服务器状态

8×RTX 4090D 服务器临时断网不可访问，标记 **UNAVAILABLE_OPTIONAL_WORKER**。项目不等待其恢复；若恢复仅作可选训练工作节点（多种子/多任务/消融/批量仿真）。

## 6. 已确认赛事事实

详见 `goai_submission_contract.md` 与 `xeval_public_recon.md`。要点：仅评测 Generalization 维度；12 基础任务 + 12 `_random` 共 24 配置；最多 3 次有效提交取最高；前 10 晋级；真机阶段 6 任务；评测方式为参赛方公网 WebSocket Policy Server（1–8 端点，ee/joint 可选）；数据仓库 `RoboDojo-Benchmark/GOAI-2026`。

## 7. UNKNOWN

见 `goai_submission_contract.md` 的 UNKNOWN 清单（评分公式、episode 数、超时、并发、端点语义等 14 项待组委会确认）。

## 8. 官方资源入口

- https://xsparkai.com/goai-2026/ 与 /apply（评测指南与申请表）
- https://xsparkai.com/en/x-eval（X-Eval 通用产品页，非 GOAI 专用规则）
- https://github.com/RoboDojo-Benchmark/RoboDojo
- https://huggingface.co/datasets/RoboDojo-Benchmark/GOAI-2026（数据）
- https://robodojo-benchmark.com/doc/（RoboDojo 官方文档）

## 9. 存储布局

代码在 `/home/cpc/projects/goai-bimaniflow`（Linux 根分区）；全部大文件在 `/data/goai-bimaniflow`（ext4 数据分区）。详见 `storage_plan.md`。

## 10–13. 事实来源

- 代码：本仓库 Git 历史
- 第三方代码：`third_party/RoboDojo` @ `36bfcb7c580b149c6e39ed2eb77d60689152e570`（main），子模块锁定见 decision_log
- 数据：仅 GOAI-2026 数据仓库 + RoboDojo-Benchmark/RoboDojo（checkpoint 仓库），以 commit SHA 锁定
- 模型/checkpoint：XPolicyLab 各 policy README + 官方下载脚本指向的 `hf://datasets/RoboDojo-Benchmark/RoboDojo/ckpt/RoboDojo/<POLICY>/`
- artifact：`/data/goai-bimaniflow/artifacts`

## 14–16. 阶段与验收

当前阶段：Phase 4A-Deploy（第一次正式提交部署）。各阶段验收见对应 docs/phase* 文档。

## 状态变更（2026-08-16）

- 用户人工完成存储扩容：根分区约 251–254 GB；新 ext4 分区 /dev/sda5 挂载 /data，约 1.7 TB 可用。
- 旧 BLOCKED_ROOT_STORAGE_POSTBUILD 已通过人工扩容解除 → **STORAGE_GATE_PASSED**。
- 工程模式切换为“有效评测提交优先”限时冲刺。

## 状态变更（2026-08-19，Phase 4A-Preflight）

- 第一次正式提交准备：提交版冻结；本地 100 次 INFER 回归通过。
- 公网条件初审：PLAN_READY_NEEDS_NETWORK_INPUT。

## 状态变更（2026-08-20 晚，Phase 4A-Deploy）

- 正式候选端点已上线：**ws://47.101.158.121:8443**（阿里云轻量 ← SSH 反向隧道（watchdog 自重启）← 127.0.0.1:6061 ACT v1）。Tailscale Funnel 因 tailnet 账户层故障弃用（443→3000 已恢复给智修同学项目）。
- 公网协议回归通过（100/100 INFER）；等待用户本人提交表单。
