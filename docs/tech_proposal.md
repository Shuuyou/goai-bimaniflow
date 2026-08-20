# BiManiFlow 技术方案

**GOAI 2026 世界人工智能开源大赛 · 具身未来赛道 · 赛题一：通用双臂协同操作挑战赛**

队伍：未竟回路（杭州电子科技大学具身智能实验室）
日期：2026 年 8 月 20 日

---

## 1. 方案概述

BiManiFlow 面向 GOAI 赛题一的 Generalization（泛化）评测维度，构建一套**可运行、可复现、可评测**的双臂机器人策略系统。本期（初赛第一次提交）的工程目标是：以官方 RoboDojo 工具链与官方 ACT checkpoint 为基线，完成从本地仿真自测到公网 X-Eval Policy Server 的完整闭环，并取得第一份真实评测结果，为后续自训练与模型升级建立可冻结、可观测、可回滚的基础设施。

核心工程原则：官方工具链优先、可运行 baseline 优先、真实评测结果优先、每一步均可验证可回滚。

## 2. 赛事契约核验

通过 GOAI 官方页面与前端资源取证确认：仅评测 Generalization 维度；12 个基础任务 ×（clean + `_random`）共 24 个配置；每队最多 3 次有效提交取最高；仿真前 10 晋级真机阶段（6 项任务）；正式评测采用参赛方提供的公网 WebSocket Policy Server（1–8 端点，动作类型 ee/joint 可选）。本地开发链路为 RoboDojo + XPolicyLab，数据与 checkpoint 来自官方 Hugging Face 仓库（RoboDojo-Benchmark/GOAI-2026 与 RoboDojo-Benchmark/RoboDojo）。

## 3. 系统架构

```
X-Eval 评测端
   │  ws://47.101.158.121:8443（公网入口，阿里云轻量服务器）
   │  SSH 反向隧道（保活 + watchdog 自重启）
   ▼
127.0.0.1:6061  ACT Policy Server（bimaniflow-act 独立 conda 环境）
   │  XPolicyLab WS 协议（msgpack，HELLO/RESET/INFER/…）
   ▼
官方 ACT adapter（未修改）→ 官方 ACT push_T checkpoint（seed_0，严格加载）
   │  RTX 5090（torch 2.7.0+cu128，sm_120）
```

本地自测链路：RoboDojo 官方 Docker 镜像（Isaac Sim 5.1 + IsaacLab + cuRobo，锁定 commit 36bfcb7）+ 宿主策略环境，经 127.0.0.1 WebSocket 连接。

关键架构决策：仿真环境与策略环境严格分离（官方镜像内 websockets 12.0 与 XPolicyLab 要求 ≥14 冲突，Policy Server 按官方架构运行于容器外独立环境）；全部大文件与缓存导向独立 ext4 数据分区，代码仓库与大文件完全隔离。

## 4. 策略配置（ACT v1，冻结）

| 项 | 值 |
|---|---|
| 模型 | ACT（Action Chunking Transformer，84M 参数，ResNet18 三路视觉 + CVAE） |
| checkpoint | 官方 act-RoboDojo-push_T/arx_x5-100-joint（revision abf44de4，sha256 校验通过） |
| seed | 0（三 seed 单 episode 筛选，见 §6） |
| 动作 | joint，14 维（双臂 6+6 + 夹爪 1+1），z-score 归一化 |
| chunk / 聚合 | chunk_size=50，temporal_agg（k=0.01） |
| 相机 | cam_head / cam_left_wrist / cam_right_wrist |
| 本体 | arx_x5 配置 / dual_x5 双臂（配置级证据链核验，非名称推断） |

## 5. 硬件兼容性实证（RTX 5090 / Blackwell sm_120）

逐项闸门验证并留存日志：CUDA 矩阵乘（torch 2.7.0+cu128，无 kernel image 错误）；Vulkan/EGL headless 图形栈；Isaac Sim 5.1 空场景启停；cuRobo 真实 CUDA FK kernel；demo_policy 协议全序列；push_T 600 步完整 episode。全程无 OOM、无架构错误。

## 6. 单 episode 实证结果（single-episode screening，非正式成绩）

- demo_policy 链路：600/600 步协议完整，结果文件与三路视频齐备。
- ACT push_T（clean，seed_0）：600/600 步，success=false；视频证据显示接触并移动了目标物体（OBJECT_MOVED_WRONG_DIRECTION）。
- ACT push_T（clean，seed_1/2）：均完成 600 步，分别为 CONTACT_FAILED / APPROACH_FAILED；据此按规则化证据选择 seed_0（置信度 MEDIUM）。
- ACT push_T_random（seed_0）：600/600 步，success=false；干扰物场景下策略行为退化但协议与执行完整（APPROACH_FAILED）。
- 推理延迟（稳态，100 次回归）：P50 22.8 ms / P95 28.3 ms / P99 116.1 ms。

以上均为单 episode 冒烟结果，不构成正式成功率；同时诚实评估：官方 checkpoint 直接提交的任务成功率预期有限，其价值在于锁定端到端链路。

## 7. 部署与可靠性

- 端点：ws://47.101.158.121:8443（SSH 反向隧道至 127.0.0.1:6061；Python 服务不直接暴露公网）。
- 守护：启动/停止脚本含 checkpoint sha256 冻结校验、端口冲突拒绝、优雅停止；隧道 watchdog 自动重连；健康检查脚本（HELLO/RESET/INFER/CLOSE）。
- 冻结纪律：审核与评测期间不更换模型、动作类型或协议行为（官方规则），版本 manifest 与配置均以 sha256 锁定。

## 8. 风险与后续路线

已识别风险：官方评分公式与 episode 数未公布；X-Eval 单步超时阈值未知（协议侧已向组委会列问题清单）；官方 ckpt 泛化能力有限。

后续路线（已有基础设施支撑）：基于 GOAI 官方 HDF5 演示数据（12 任务 ×100 episodes，已审计 154.8 GB 清单）在 RTX 5090 上自训练 ACT，并推进 random 维度泛化增强；备选评估 Pi_05 等官方已适配的强基线（完整 adapter 与公开权重已静态核验）。

## 9. 开源说明

本仓库包含全部工程文档、审计记录、运行脚本、提交配置与证据索引；遵循上游许可证（RoboDojo 非商业研究许可声明、XPolicyLab Apache-2.0、IsaacLab BSD-3、cuRobo Apache-2.0），不再分发官方数据与权重，仅提供官方来源引用与校验 hash。

---

*联系：杭州电子科技大学具身智能实验室*
