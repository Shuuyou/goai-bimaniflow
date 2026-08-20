# Phase 3A-R smoke 结果：push_T 单 episode（demo_policy）

日期：2026-08-17（+0800）。**demo_policy 为零动作虚拟策略，本结果仅证明链路与协议可运行，不是任何模型成绩。**

| 项 | 值 |
|---|---|
| 完整命令 | `docker run --name bimaniflow-sim-client --network host --ipc host --init --gpus '"device=0"' -e NVIDIA_DRIVER_CAPABILITIES=all -v <Assets 双挂载 ro> -v <eval_result/caches/kit-logs> goai-bimaniflow/robodojo:36bfcb7 bash scripts/robodojo.sh client --task push_T --policy-name demo_policy --policy-host 127.0.0.1 --policy-port 6060 --ckpt smoke --eval-num 1 --action-type joint --env-gpu 0` |
| commit SHA | RoboDojo 36bfcb7c580b149c6e39ed2eb77d60689152e570；XPolicyLab 432f82b1758c5b1202e42a3dfe014546dbc50871；IsaacLab afca7b09d60d8beb9c1cb28b43066499940b969b；curobo d17b54ce32cba095c0b000c4c58777075d11de0e；GOAI-2026 数据 8ca75af1ff79c30c4b9fbc552b99bac206bc014d |
| 镜像 ID | sha256:cc083b0887ecc49f721c8c81bae4821e36355291c7acce2d43dee1e30d3c7c6a |
| 任务 / 配置 | push_T（registry 名；官方 slug push-t） |
| embodiment | arx_x5（dual_x5 双臂，arm 6+6，gripper 1+1） |
| action type | joint |
| episode 数 | 1（layout_id 0，eval seed 0） |
| 启动耗时 | Sim 启动 436s；场景+MDL/着色器首次编译 ~20 min（冷缓存） |
| 推理延迟 | 协议内 latency_ms 未打印到日志 → UNKNOWN（600 步内全部成功，无超时） |
| episode 结束方式 | 达到官方 step_lim=600 自然终止（fail 判定，预期内） |
| 结果文件 | eval_result/.../2026-08-16_23-50-25/_result.json + 3 路相机视频（601 帧） |
| GPU 峰值显存 | UNMEASURED（未采样；无 OOM 发生） |
| 根分区增量 | ≈0 GB |
| /data 增量 | ≈0.8 GB（isaac 缓存 + kit 日志 + 结果） |
| 警告 | GLFW/audio/USD material binding 越界引用/zenity 缺失——均非阻断 |
| 结论 | **VERIFIED**：Isaac Sim 场景加载 ✓ push_T 配置解析 ✓ Policy Server 连接 ✓ RESET ✓ 600 步动作循环 ✓ 动作结构合法 ✓ episode 正常结束 ✓ 结果文件生成 ✓ 仿真器与服务正常退出 ✓ 无遗留容器/GPU 进程 ✓ |
