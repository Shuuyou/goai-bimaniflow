# X-Eval 正式评测申请检查单（Phase 4A）

⚠️ 表单必须由用户本人在 https://xsparkai.com/goai-2026/apply 填写并提交。任何人不得代填。官方后端字段：team_name / contact_name / phone / email / policy_server_urls[] / policy_name / action_type。

## 报名与人

- [ ] GOAI 官网报名已完成（人工确认）
- 队伍名称：未竟回路
- 联系人：________（人工填写）
- 手机号：________（人工填写，中国大陆）
- 邮箱：________（人工填写）

## 端点与策略

- 公网 Host：**47.101.158.121**（阿里云轻量服务器）
- 公网端口：**8443**（SSH 反向隧道 → 127.0.0.1:6061；阿里云防火墙已放行）
- 端点数量：1（默认；1–8 语义 UNKNOWN，已列入待组委会确认问题）
- 策略名称：**BiManiFlow_ACT_v1**（仅字母/数字/下划线 ✓）
- 动作类型：**joint**
- checkpoint sha256：d41ea255207ceea13b7aa1707d073aae7c38d1b826b5f08b0d82588ad3c41b1a（policy_epoch_6000_seed_0.ckpt）
- manifest sha256：3d65ad8195a6f49c769c2dcdf4c821cdf91f7f3c1ecfc90fa12dc62596e2cd80
- act_v1.yaml sha256：c8101a6b45eaf7929999da439be64d9f8e1b21411b15c57a5820dfac6f3156de

## 就绪证据

- [x] 本地 100 次 INFER 回归通过（docs/phase4a_local_regression.md：P50 22.8 / P99 116.1 ms）
- [x] 公网端点协议回归通过（100/100 INFER，见 phase4a_external_connectivity.md）；[ ] 用户手机/外部机器 426 确认（待回填）
- TLS：本端点为 ws://（官方前端实际提交格式）；TLS 到期时间：不适用（wss 是否强制待组委会确认）
- 服务启动时间：2026-08-20（ACT v1，127.0.0.1:6061，healthcheck 13.2 ms）
- 服务 PID/容器状态：________（提交前记录）
- GPU 空闲显存：________（提交前测量）
- 磁盘：根分区 285 GB / /data 1.7 TB（2026-08-19 基线）
- 日志路径：logs/phase4a/、/data/goai-bimaniflow/logs/

## 提交后（留空）

- 申请提交时间：________
- 申请编号：________
- 审核状态：________
- 结果邮件状态：________（务必保存，官网提交作品的必要附件）

## 冻结纪律提醒

审核与正式评测期间：保持同一服务在线；不更换模型、动作类型或协议行为（官方规则原文）。三次有效提交机会，不要在未自测的情况下消耗。
