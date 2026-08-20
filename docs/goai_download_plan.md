# GOAI 数据分阶段下载计划（Download Plan）

日期：2026-08-12。下载目标在数据分区（/data/goai-bimaniflow）。锁定方法：hf `--revision 8ca75af1ff79c30c4b9fbc552b99bac206bc014d`。校验：HF 下载自带 LFS SHA 校验 + 逐文件 sha256 复核。

## Stage 0 — 代码与子模块（已完成）

- 内容：`git clone --recurse-submodules`，`GIT_LFS_SKIP_SMUDGE=1`
- 实际：616 MB（third_party/RoboDojo）；LFS 大文件未获取
- 状态：DONE @ RoboDojo 36bfcb7

## Stage 1 — 最小 smoke 资产（已完成，push_T 闭包）

- 内容：Room/Simple_Room_nolight、Material/material_0122、material_0564、Background HDR、Sensor、Geometry/camera_stand+t_cushion、Rigid/t、Robots/x5、Eval_Layout push_T seed-0 布局
- 实际：424 MB（326 文件）
- 方法：从预生成布局 JSON 推导精确闭包（含 Room/Table/Ground/Background 段——3C-R 教训固化）

## Stage 2 — 12 基础任务资产（Generalization 必需，待执行）

- 内容：完整 `Assets/**`（官方指南 3.3）
- 预计：32.71 GB；单文件最大 423 MB
- 红线：完成后数据分区 ≥1.5 TB

## Stage 3 — random 配置额外资产

- 内容：**基本无**（_random 复用同一 Assets 树；差异化场景材质随布局闭包补齐，实测 push_T_random 仅 +150 MB）

## Stage 4 — HDF5 演示数据（按 baseline 选择分批，待执行）

- 内容：`data/hdf5/<task>/arx_x5/**`，按训练需要逐任务下载
- 单任务 5.5–20.8 GB；12 任务合计 154.76 GB
- LeRobot 变体（各 34.72 GB）仅在选用直接消费 LeRobot 的 baseline 时下载其一

## Stage 5 — 候选模型 checkpoint

- 已完成 ACT push_T（961 MB，sha256 全验）；其余按需逐 policy 下载
- 红线：完成后数据分区 ≥1 TB

## 每阶段通用项

- 官方来源：HF 主站；失败再考虑 ModelScope 镜像（同名仓库）
- 根分区占用：各阶段 ≈0；缓存指向数据分区
- 任何阶段预计使数据分区跌破红线 → 停止并标记 BLOCKED_DATA_STORAGE
