# BiManiFlow — GOAI 2026 具身未来赛道·赛题一

通用双臂协同操作挑战赛参赛工程（队伍：未竟回路，杭州电子科技大学具身智能实验室）。

## 这是什么

基于官方 **RoboDojo**（仿真评测）+ **XPolicyLab**（策略服务协议）工具链的双臂策略评测工程：

- 官方 ACT checkpoint（push_T, arx_x5/dual_x5 双臂）的契约核验、三 seed 筛选与单 episode 实证
- RTX 5090（Blackwell sm_120）全链路验证：CUDA / EGL/Vulkan / Isaac Sim 5.1 headless / cuRobo / WebSocket 协议
- 公网 X-Eval Policy Server 部署（云主机 SSH 反向隧道 + 本地 127.0.0.1 策略服务，冻结版本管理）
- 全过程审计文档与证据日志索引（见 `docs/`）

## 结构

- `docs/` — 项目状态、决策日志、赛事契约、各阶段闸门记录（Phase 0R → 4A）
- `configs/` — 实验与提交配置（`configs/submission/act_v1.yaml` 为冻结提交版）
- `scripts/` — Preflight、smoke、seed sweep、延迟探针、服务启停、隧道守护
- `compose.robodojo.yaml` — 官方镜像的外层 compose 封装
- 上游代码（RoboDojo/XPolicyLab/IsaacLab/cuRobo）以锁定 commit 的 third_party 引用，不入库

## 复现入口

1. 克隆 RoboDojo（锁定 commit 见 `docs/submission_version_manifest.md`）
2. 按 `docs/phase3a_container_build.md` 构建官方镜像
3. 按 `docs/phase3b_act_environment_plan.md` 建立策略环境
4. `scripts/phase4a_start_policy.sh` 启动冻结版 ACT 服务

技术方案与评测证据索引见 `docs/tech_proposal.md` 与 `docs/x_eval_submission_checklist.md`。

## 许可证

本文档与脚本 Apache-2.0；上游组件各自许可证见 `docs/license_audit.md`。官方数据与权重不再分发。
