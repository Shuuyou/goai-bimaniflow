# Phase 3A Preflight

日期：2026-08-12。阶段：官方 Docker 最小环境 + RTX 5090 图形栈 + demo_policy 单任务链路验证。

## 步骤 A：项目冻结（通过）

- 主仓库 HEAD：`9b76b7b chore: bootstrap 5090 recovery and audit RoboDojo stack`（审计基线 commit），工作树干净，`git diff --check` OK。
- RoboDojo @ `36bfcb7c580b149c6e39ed2eb77d60689152e570`，工作树干净。
- 子模块：XPolicyLab `432f82b1…`，IsaacLab `afca7b09…`，curobo `d17b54ce…` —— 与锁定一致，工作树干净。

## 步骤 B：资源基线

- 根分区 /dev/sda4：**250 GB 可用（91%）**；inode 5%。→ 构建前红线 ≥200 GB：**PASS**
- 数据盘：2.7 TB 可用。
- Docker：Images 247 GB / Containers 27.3 GB / Volumes 30.1 GB / Build Cache 258.3 GB（其他项目，不动）。
- GPU：1407 MiB / 32607 MiB（仅桌面进程）。**PID 8188 已不存在**，上一阶段的 8 GiB python 负载已自行结束。可用显存约 30.6 GiB ≥ 22 GiB：**PASS**
- 与本项目相邻的既有镜像：`nvidia/cuda:12.8.0-devel-ubuntu22.04`（其他项目，非 12.8.1-cudnn-devel，不能冒充官方基础镜像）。

## 风险预警（构建前）

- 官方 docker/README.md:46 称镜像“非常大（含全部 Isaac Sim 扩展缓存约 200 GB），建议 300 GB+ 空闲”。本机根分区仅 250 GB。
- 决策：继续构建（Dockerfile `isaacsim[all,extscache]` 为官方默认；禁改上游）。构建期间监控根分区；若预计跌破 150 GB 立即中止构建并标记 BLOCKED_ROOT_STORAGE_PREBUILD/POSTBUILD。构建后按红线复核，不达标则不启动容器。
- 预计下载：基础镜像 cudnn-devel-12.8.1 ~3 GB（压缩）+ pip Isaac Sim/torch/curobo 依赖 ~20 GB；镜像落盘估 40–80 GB。

## GPU 规则状态

- GPU0 单卡；不多 GPU、不并发仿真；完成后复核无遗留。

## 复核（2026-08-16）

- 根分区 254 GB（用户人工整理后）；/data ext4 1.7 TB（用户人工分区）。STORAGE_GATE_PASSED。
- GPU 现状：其他项目进程 PID 3311250（~8 GB）、846219（~2.7 GB），可用 ~20.7 GiB；本项目不干预。
