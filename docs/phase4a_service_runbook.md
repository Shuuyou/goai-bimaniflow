# Phase 4A：ACT v1 Policy Server 运行守护 Runbook

范围：仅 127.0.0.1 本地 Policy Server + 公网转发层。正式评测期间不得更换模型、action_type、协议行为或服务实现。

## 1. 启动

```bash
bash scripts/phase4a_start_policy.sh
```
（原子检查端口空闲 → checkpoint sha256 冻结校验 → nohup 启动 bimaniflow-act 环境的官方 setup_policy_server.py → 等待端口 → 写 PID 文件）

## 2. 停止

```bash
bash scripts/phase4a_stop_policy.sh
```
（读 PID 文件 → SIGINT/SIGTERM → 等待退出 → 验证端口释放；不得 pkill 其他项目进程）

## 3. 健康检查

```bash
conda run -n bimaniflow-act python scripts/phase4a_healthcheck.py   # exit 0/1
```
内容：端口可连接 → 官方 WsModelClient HELLO → RESET → 一次 INFER（官方 debug client 观测生成器）→ CLOSE；输出延迟 ms。

## 4. PID 管理

logs/phase4a/policy_server.pid 单文件；启动前校验旧 PID 是否存活且 cmdline 匹配 setup_policy_server；不匹配则拒绝启动并报告。

## 5-6. 日志与轮转

stdout/stderr → logs/phase4a/policy_server.log；轮转：每次启动前若 >200 MB 则 rename（保留 3 份）；不落盘图像/完整 observation。

## 7-10. 故障处理

- GPU OOM：服务日志出现 CUDA out of memory → 停止服务 → 报告 → 人工处理（不自动量化/降级）。
- checkpoint 加载失败（FileNotFoundError/strict key 错误）：启动即失败 → 报告并回滚检查 symlink。
- 端口占用：start 脚本检测 6061 被占且 PID 不属于本项目 → 拒绝启动并报告（不抢端口）。
- 崩溃恢复：仅允许“相同配置的进程重启”，最多自动重启 1 次并告警；禁止任何配置漂移。
- 卡死判定：healthcheck 连续 3 次超时（INFER > 5s 异常）→ 判定卡死 → 走安全停止流程。

## 11-12. 冻结纪律

正式评测期间：不重启（除崩溃恢复）、不换 checkpoint、不改 deploy 参数、不滚动更新、不并行第二实例。

## 13. 协议确认方式

- reset：RESET 后下一次 INFER 返回形状/有限性正常（temporal_agg t 归零）。
- 重复 request ID：客户端同一 request_id 重发 → 服务端 replay cache 命中（日志 "duplicate request ... replaying"）。
- heartbeat：HEARTBEAT → HEARTBEAT_ACK ok=true。
- close：CLOSE 后服务端关闭连接，进程仍存活（keepalive 由 websockets ping 20s/20s 承担）。

## 14-16. 状态判断与安全停止

- 接受连接中：`ss -tln | grep 6061` 且 healthcheck exit 0。
- 卡死：healthcheck 连续超时 / server 日志无进展且 GPU 显存不变。
- 安全停止：phase4a_stop_policy.sh（先 SIGINT，10s 后 SIGTERM，再 10s 后报告人工处理，不用 SIGKILL 作为默认）。

## 17. 断电/重启后人工恢复

1. 确认 nvidia-smi 正常；2. 确认 symlink：`readlink .../policy_last.ckpt` = policy_epoch_6000_seed_0.ckpt 且 sha256 匹配 d41ea255…；3. `bash scripts/phase4a_start_policy.sh`；4. healthcheck；5. 隧道 watchdog 需一并恢复（scripts/phase4a_tunnel_watchdog.sh）；6. 记录恢复事件。

## 18-19. 日志纪律与归档

不落盘图像与完整 observation；评测结束后：结果 JSON/视频/server 日志归档到 /data/goai-bimaniflow/artifacts/<phase>/，并在 decision_log 记录。

## 20. 回滚到 ACT v1

ACT v1 即当前唯一版本；回滚 = 恢复本 runbook 配置。若环境损坏：`conda env remove -n bimaniflow-act` 后按 docs/phase3b_act_environment_plan.md 重建。

## 守护形态决策

首选**受控 nohup + PID 文件 + 显式启停脚本**；隧道由 scripts/phase4a_tunnel_watchdog.sh 守护（ssh 保活 + 断线 5s 重连）。未创建系统级 systemd unit。
