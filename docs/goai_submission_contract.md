# GOAI 提交契约（Submission Contract）

日期：2026-08-12。事实来源：`https://xsparkai.com/goai-2026/` 与 `/apply`（前端 bundle 内嵌指南，GET 取证）。

## 已确认事实

1. 仅评测 RoboDojo **Generalization（泛化能力）维度**。
2. **12 个基础任务**：arrange_largest_number, fold_clothes, hang_mugs, make_toast, pack_objects_into_box, pour_liquid_into_cup, push_T, sort_nesting_dolls_by_size, stack_blocks, stack_bowls, store_laptop_and_headphones, sweep_blocks。
3. 每个基础任务有对应 `_random` 随机化配置，共 **24 个可运行配置**（仓库实测全部存在）。
4. 每队最多 **3 次有效提交，取最高成绩**；“不要使用正式提交机会调试策略”。
5. 评测“不仅看任务成功率，还综合考察任务完成质量、执行效果、系统性能、鲁棒性与泛化能力”；**总分前 10 晋级**。
6. 真机阶段：6 项任务，三天线下现场测试机会；决赛 9.22–9.23。
7. **正式仿真评测 = 参赛方提供的公网 WebSocket Policy Server**。禁止 localhost/局域网 IP；建议固定公网 IP 或稳定域名并启用 TLS。
8. 申请表字段：队伍名称、联系人、手机号、邮箱、Policy Server 端点 1–8 个（主机+端口，不可重复）、策略名（仅字母/数字/下划线）、动作类型 ee/joint。后端 `POST /api/v1/goai/simulation-applications/`。
9. 审核通过后开始评测；审核与评测期间保持同一服务在线、不更换模型/动作类型/协议行为；结果邮件为官网提交作品的必要附件。
10. 赛程（AOE）：报名 7.16；**初赛 7.16–8.20**；评审 8.21–8.23；决赛前调试 8.25–9.20；决赛 9.22–9.23。
11. 官方冒烟命令：`bash scripts/robodojo.sh smoke --dimension generalization --policy-dir … --eval-env RoboDojo --action-type … --eval-num 1`（12+12 配置各 1 episode）。
12. 资产与数据仅从 `RoboDojo-Benchmark/GOAI-2026` 获取（`Assets/**`、`data/hdf5/**`）。
13. 安装链路：clone `--recurse-submodules` → `bash scripts/install.sh -i` → `conda activate RoboDojo`。

## 冲突（需核实）

- 指南文字写 `wss://host:port`，前端代码实际生成 `ws://host:port`。是否强制 TLS 待确认。

## UNKNOWN（正式规则未公布）

评分公式；每任务 episode 数；clean/random 权重；单步超时；平均延迟限制；并发连接；最大消息体；ping/pong 与断线重试；GPU 限制；ensemble 规则；测试时适应规则；外部 API；日志/视频回传；1–8 端点准确含义。
- X-Eval 产品页 50 任务排行榜公式（40% Clean + 60% Randomized）仅属 VERIFIED_XEVAL_GENERAL，**不是** GOAI 正式公式。

## 待组委会确认的问题（草稿，未发送）

1. 是否允许用官方演示数据本地训练 + 远程 Policy Server 接受正式评测？
2. 每个基础任务和 random 配置分别运行多少 episode？
3. GOAI 正式评分公式？
4. Clean 和 random 权重？
5. 单步响应超时和平均延迟要求？
6. 最大并发连接数？
7. 单条 WebSocket 消息大小限制？
8. ping/pong、断线重连和请求重试规则？
9. 1–8 个端点的用途（并行/冗余/多版本）？
10. 同一 checkpoint 可否部署到多个端点？
11. 是否允许 ensemble 和测试时适应？
12. Policy Server 是否允许调用外部 API？
13. 评测视频、日志和逐任务指标是否回传？
14. 真机阶段机器人本体、控制接口和任务何时公布？
15. `wss://` 还是 `ws://` 为正式提交协议？是否强制 TLS？
