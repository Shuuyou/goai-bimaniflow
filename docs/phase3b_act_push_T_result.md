# Phase 3B：ACT push_T 单 episode 结果（single-episode smoke result）

日期：2026-08-17。**本结果为 single-episode smoke result，不是正式任务成功率、正式平均成绩、X-Eval 成绩或排行榜成绩。**

## 来源与环境

- checkpoint：`RoboDojo-Benchmark/RoboDojo`（dataset）@ `abf44de4b10b5c7efdc68f07630157329dbbcb7f`，路径 `ckpt/RoboDojo/ACT/act-RoboDojo-push_T/arx_x5-100-joint`；license 标签 apache-2.0。
- 文件：dataset_stats.pkl + policy_epoch_6000_seed_{0,1,2}.ckpt（各 335.9 MB，共 961.1 MB），sha256 与官方 LFS oid 全部匹配。评测用 seed_0（本地符号链接 `policy_last.ckpt -> policy_epoch_6000_seed_0.ckpt`）。
- 策略环境：bimaniflow-act（宿主 conda，python 3.11，torch 2.7.0+cu128，numpy 1.26.4；pip check 无冲突；与官方镜像完全隔离）。
- 仿真环境：官方镜像 goai-bimaniflow/robodojo:36bfcb7（ID sha256:cc083b0887ec…c7c6a，未修改未重建）。

## 契约核验

- embodiment：arx_x5 = env_cfg 命名，机器人本体 dual_x5——证据链核验，非目录名推断。
- action type：joint；action_dim=14；夹爪在索引 6、13；z-score 归一化。
- 相机：cam_head / cam_right_wrist / cam_left_wrist；chunk_size=50；temporal_agg=true（k=0.01）；84M 参数。
- 加载：官方严格 `load_state_dict`（默认 strict）成功，无 missing/unexpected keys；加载 118s；首 forward 46.5s（cuDNN autotune）。

## Gate B7（debug client + 延迟）

- 官方 debug client：1 episode × 20 步，exit 0。
- 延迟探针（复用官方 TestEnv/WsModelClient，仅加计时）：首次推理 47.9 ms；稳态 N=29：**mean 23.1 / P50 22.8 / P95 24.9 / P99 25.7 / max 26.0 ms**；动作键齐全、float64、有限；reset 正常；服务正常退出。
- ACT server 常驻显存：4012 MiB。

## Gate B8：push_T 单 episode

- 命令：`docker run … goai-bimaniflow/robodojo:36bfcb7 bash scripts/robodojo.sh client --task push_T --policy-name ACT --policy-host 127.0.0.1 --policy-port 6061 --ckpt act-RoboDojo-push_T/arx_x5-100-joint --eval-num 1 --action-type joint --env-gpu 0`
- 时间线：run#1 在 45 分钟超时（冷编译 + 主机负载）；run#2（90 分钟预算）完成 600/600 步，Simulation App 正常关闭，exit 0。
- 结果：`_result.json` = success_rate 0.0 / eval_time 1 / score 0.0 / details.0.success=false（layout 0）。**结束原因：达到官方 step_lim=600 自然终止，任务未成功（smoke 允许失败）。**
- 视频：3 路相机各 601 帧 640×480@25fps fail mp4。
- GPU：整机峰值显存 13,732 MiB（含其他项目 ~8.7 GB + ACT 4.0 GB + 仿真）；无 OOM。
- 推理延迟（episode 内）：未逐步插桩；以 B7 稳态 P50 22.8 / P99 25.7 ms 为参考，episode 600 步全部在 keepalive 窗口内完成无超时。
- 磁盘增量：根分区 ≈0；/data ≈+5.3 GB。
- 网络请求：全部为 GET；无 POST。
- 警告：GLFW/audio/USD material binding/zenity 缺失（非阻断）；torchvision pretrained 参数弃用警告（官方代码路径）。

## 结论

**VERIFIED**：官方 ACT push_T checkpoint 与 GOAI dual_x5 embodiment 直接兼容；真实策略闭环（ACT Policy Server → WS → RoboDojo 仿真 → 600 步 → 结果与视频）完整跑通。
