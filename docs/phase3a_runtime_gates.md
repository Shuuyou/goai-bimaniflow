# Phase 3A-R 运行时闸门记录

日期：2026-08-16/17。镜像：goai-bimaniflow/robodojo:36bfcb7（ID sha256:cc083b0887ec…c7c6a，全程未变）。

## Gate 0：存储与镜像复核 — **STORAGE_GATE_PASSED**

- 2026-08-16 20:51 +0800；根分区 254 GB ≥220 ✓；/data ext4 1.7 TB ≥1.5 TB ✓；/data/goai-bimaniflow 可写 ✓
- 目标镜像 ID 一致 ✓；无构建进程；无本项目容器 ✓
- GPU：其他项目进程占 ~10.6 GB，可用 ~20.7 GiB（不干预）
- /data 目录树、.env.local（Git 忽略）、.env.example 更新完成；424 MB Assets 迁移至 /data/goai-bimaniflow/assets/Assets，curobo.yml 由官方脚本重新生成

## Gate E1：CUDA — **CUDA_GATE_PASSED**

- python 3.11.15 / torch 2.7.0+cu128 / CUDA 12.8 / device_count 1 / "NVIDIA GeForce RTX 5090" / capability (12, 0)
- 总显存 31.4 GiB；探针时空闲 20728 MiB
- 512×512 与 2048×2048 matmul + synchronize 全部成功；首个 kernel 9.06s（含初始化）；峰值显存 57 MB
- 未出现 no kernel image / invalid device function / unsupported sm / PTX JIT failure / CUDA OOM

## Gate F1：EGL/Vulkan/Isaac headless — **ISAAC_HEADLESS_GATE_PASSED**

- NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics ✓；Vulkan instance 1.3.204，GPU0 = RTX 5090（NVIDIA proprietary，api 1.4.325）；EGL vendor json 与 VK_ICD 单锁定生效
- Isaac Sim 5.1 headless 空场景：ISAAC_APP_UP 580.3s → 新 stage → 10 次 update → ISAAC_EXIT_OK 586.6s，EXIT=0，无遗留容器/进程
- 单次正式尝试，无重试

## Gate G1：cuRobo runtime — **CUROBO_GATE_PASSED**

- 官方 API（本 fork 扁平化布局）：`KinematicsCfg.from_robot_yaml_file(.../x5/curobo.yml)` + `Kinematics.compute_kinematics(JointState)`
- 配置加载 46.9s，FK CUDA kernel 完成于 83.4s（含 warp JIT），6 关节，结果有限，EXIT=0
- 无 Blackwell 架构错误 / no kernel image / invalid device function；缓存写入 /data/goai-bimaniflow/cache/curobo（warp）
- 未修改源码与 TORCH_CUDA_ARCH_LIST

## Gate J1：demo_policy 协议 — **POLICY_PROTOCOL_GATE_PASSED**

- 关键发现：官方镜像内 websockets==12.0（Dockerfile:177 repin）与锁定 XPolicyLab 要求 websockets>=14.0 冲突，镜像内 ws server 无法启动（websockets.asyncio 缺失）。按官方架构（policy server 运行于容器外独立环境）在宿主建 `bimaniflow-demo` conda 环境运行 demo_policy（决策记录 decision_log#24）
- 服务绑定 127.0.0.1:6060，无 TLS；官方 debug client（--protocol ws）完成：连接 → 1 episode × 20 步（RESET → 逐步 update_obs/get_action → TRIAL_END → CLOSE），EXIT=0
- 动作维度从 dual_x5 实际配置读取（arm [6,6] + gripper [1,1]），joint 模式键 left/right_arm_joint_state + left/right_ee_joint_state，dtype float32；全流程无 NaN/Inf
- 重复 request-id cache 重放：静态代码已验证（model_server.py:294-332），本次运行未触发——如实标记 UNEXERCISED
- 服务事后正常终止、端口释放、无僵尸进程

## Gate K1：push_T 单 episode — **VERIFIED**

- 命令：`docker run … goai-bimaniflow/robodojo:36bfcb7 bash scripts/robodojo.sh client --task push_T --policy-name demo_policy --policy-host 127.0.0.1 --policy-port 6060 --ckpt smoke --eval-num 1 --action-type joint --env-gpu 0`
- 时间线：Sim 启动 436s → 场景加载与 MDL/着色器编译（sm_120 首次，约 20 分钟）→ 600/600 步全部执行（step_lim 600 自然终止）→ 结果写出 → 正常关闭，EXIT=0
- 结果文件：eval_result/.../2026-08-16_23-50-25/_result.json：`{"success_rate": 0.0, "eval_time": 1, "score": 0.0, details.0.success=false}`（与官方 demo_policy 期望格式一致；**demo_policy 结果不构成模型成绩**）
- 视频：3 个相机各 601 帧 640×480@25fps fail mp4
- Policy 侧：600 次观测上报 + 300 次动作生成 + reset 正常
- 警告：GLFW headless、audio device、USD material binding 越界引用（官方资产既有）、zenity 缺失（Kit hang 检测器兜底，无副作用）——全部非阻断
- 失败历史（如实记录）：run#1 30 分钟超时（冷编译未完成）；run#2 场景加载完成但 WS keepalive 超时（demo server 被我方先前 SIGINT 打断），重启 server 后 run#3 通过
- 根分区增量 ~0，/data 增量 ~0.8 GB（缓存+结果+kit 日志）

## 闸门总览

STORAGE_GATE_PASSED → CUDA_GATE_PASSED → ISAAC_HEADLESS_GATE_PASSED → CUROBO_GATE_PASSED → POLICY_PROTOCOL_GATE_PASSED → K1 push_T VERIFIED
