# 决策日志（Decision Log）

## 2026-08-12 — Phase 0R 灾难恢复与审计

1. **4090D 服务器临时断网**（8×RTX 4090D）→ 标记 `UNAVAILABLE_OPTIONAL_WORKER`。不从其恢复任何文件/commit/镜像/日志。
2. **5090 节点（Baiyang-5090-1）成为唯一主节点**，不等待旧服务器恢复。
3. **单卡可运行成为硬约束**。
4. **Git 与运行环境保留在 Linux 根分区**——fuseblk 不适合 POSIX 语义工作负载。
5. **数据、模型、artifact、缓存规划到大容量分区**。
6. **fuseblk 不用于 Docker overlay、Conda、主 Git 工作树**（实测 chmod 无效、owner root:root，见 windows_d_storage_compatibility.md）。
7. **Docker Root Dir 位于空间紧张的根分区**；Docker 账面占用 ~560 GB 属其他项目，禁止清理。
8. **静态审计完成前不安装、不构建镜像、不下载完整数据、不运行仿真/训练/Policy Server**。
9. **XPolicyLab 使用 RoboDojo 锁定的子模块版本** `432f82b1758c5b1202e42a3dfe014546dbc50871`，不另行克隆最新 main。
10. **官方页面为 JS SPA**；取证通过 GET 获取前端 bundle 并提取内嵌指南文本与赛程（见 xeval_public_recon.md）。
11. **许可证冲突记录**：RoboDojo 根 `LICENSE` 文件为 MIT 文本，但 README 与 badge 声明 “RoboDojo Non-Commercial Research License”。按更严格者对待（见 license_audit.md）。
12. **RTX 5090 (sm_120) 兼容性**：官方栈 torch 2.7.0+cu128 / Isaac Sim 5.1.0；`TORCH_CUDA_ARCH_LIST` 不含 sm_120——记录矩阵，后续实证关闭（见 rtx5090_compatibility.md）。
13. **Docker 构建 DNS**：首次构建在 torch cu128 下载阶段因构建容器 DNS 瞬态失败。采用 `docker build --network=host` 重试（唯一一次），不触碰系统配置。
14. **PROCESS_DEVIATION_ASSET_DOWNLOADED_BEFORE_GATES**：步骤 H/I（push_T 选择与 424 MB 资产下载）在构建与探针闸门之前执行，违反阶段顺序。来源 GOAI-2026 @ 8ca75af，清单 logs/phase3a/asset_manifest{,_sha256}.txt，未运行、未启动仿真。纠正：保留资产、停止进一步下载、不删除重复下载，后续步骤等待构建审计与人工闸门。
15. **任务命名核验**：官方文档 slug `push-t` ≠ RoboDojo registry/CLI 名 `push_T` ≠ random 配置 `push_T_random`；本项目 CLI/配置统一用 `push_T`。
16. **缓存表述修正**：`--network=host` 改变 BuildKit 缓存键，联网 RUN 层自 apt 起重新执行；torch/Isaac Sim 层本无缓存可复用。

## 2026-08-16 — 人工存储扩容与冲刺模式切换

17. **人工扩容（用户完成）**：根分区 ~251–254 GB；新 ext4 分区 /dev/sda5 挂载 /data，~1.7 TB。Docker data-root 不迁移；不再分区、不再清理 Docker。用户另人工执行过 `docker builder prune -f`。
18. **BLOCKED_ROOT_STORAGE_POSTBUILD 解除** → STORAGE_GATE_PASSED。BuildKit 定向清理仅释放约 3.2 GB 的结论保留（75.4 GB 批准 cache 中 70.94 GB 与目标镜像共享内容不可释放）。
19. **最终存储布局**：代码/Git 在根分区；全部大文件导向 /data/goai-bimaniflow。
20. **模式切换**：“有效评测提交优先”限时冲刺（初赛截止 2026-08-20 AOE）。GPU 上其他项目进程保留不干预。
21. **依赖状态保持**：PIP_CONFLICTS_PRESENT / KEY_IMPORTS_PASS / RUNTIME_IMPACT_UNKNOWN / NO_DEPENDENCY_CHANGES_ALLOWED_YET。
22. **运行时显存阈值调整**：停止条件改为“可用显存低于任务启动所需”，preflight 运行时阈值 12 GiB。
23. **preflight 主仓库 dirty 检查降级为告警**（Phase 3A-R 允许编辑清单内文件）；上游完整性检查保持硬失败。
24. **demo_policy 宿主轻量策略环境**：官方镜像 websockets==12.0 与 XPolicyLab>=14 冲突，镜像内 ws server 无法启动；按官方架构（Policy Server 在容器外独立环境）在宿主建 bimaniflow-demo 环境。不修改镜像依赖。
25. **K1 超时预算调整**：冷缓存下 Isaac Sim 启动+场景/着色器编译远超 30 分钟；K1 外层超时仅首次调整为 90 分钟。WS 服务端曾被我方 SIGINT 打断致 ping timeout，server 重启后通过。
26. **B8 首次超时与精确重试**：45 分钟超时于启动阶段（主机负载），run#2 仅调整外层超时后通过。
27. **3C-R 资产闭包两轮**：首轮遗漏 random 布局差异化场景资产（Room teal/材质），run#1 基础设施失败；静态补齐后 run#2 通过。教训固化：闭包推导必须覆盖布局 JSON 的 Room/Table/Ground/Background 段。

## 2026-08-19 — Phase 4A Preflight

28. **公网审计**：本机无公网 IP（NAT 后），Tailscale Funnel 存在但连通性存疑；无 nginx/caddy；无本地证书。状态 PLAN_READY_NEEDS_NETWORK_INPUT。系统当日午间曾重启一次，重启后复核干净。
29. **提交版冻结**：ACT v1 = 官方 push_T ckpt seed_0（d41ea255…）+ joint/14 维/chunk50/k0.01；bimaniflow-act 环境；server 仅 127.0.0.1:6061。manifest/act_v1.yaml hash 记录于 logs/phase4a/submission_hashes.txt。100 次本地 INFER 回归通过。

## 2026-08-20 — Phase 4A-Deploy

30. **网络路径**：Tailscale Funnel 公网 TLS 长期不通（重声明与 off/on 重注册均无效，判定 tailnet 账户/签发层问题，弃用；443→3000 恢复给智修同学项目）。改用用户购置的阿里云轻量服务器（公网 IP）+ SSH 密钥反向隧道（拒绝使用密码登录命令行；部署密钥 ~/.ssh/bimaniflow_deploy 仅本项目）。云端 8443 对公网 → 127.0.0.1:6061 ACT v1。提交端点 ws://<云IP>:8443（官方前端实际按 ws:// 提交；wss 为指南建议项——冲突记录在案）。
31. **延迟事实**：经隧道本机回路 P50 ~1.6s 由家庭上行带宽主导（观测上行 ~2.8MB/步）；正式评测观测方向为下行到本机、动作上行 KB 级，方向不对称，预计不构成瓶颈；X-Eval 单步超时阈值仍 UNKNOWN（待组委会确认）。
