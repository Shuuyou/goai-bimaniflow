# X-Eval / GOAI 公开页面取证（Public Recon）

日期：2026-08-12。方法：仅 GET/HEAD，低频串行，未提交表单、未使用登录态。

## 请求清单

| # | URL | 结果 |
|---|---|---|
| 1 | https://xsparkai.com/goai-2026/ | 200，SPA 壳（792 B） |
| 2 | https://xsparkai.com/goai-2026/assets/index-J1Id2EKy.js | 200，292,782 B（指南全文内嵌） |
| 3 | https://xsparkai.com/goai-2026/apply | 200，表单字段提取成功 |
| 4 | https://xsparkai.com/en/x-eval | 200，X-Eval 通用产品页 |

## VERIFIED_GOAI_OFFICIAL

- 仅评测 Generalization 维度；12 基础任务 + 12 `_random` 配置，共 24 个可运行配置。
- 最多 3 次有效提交取最高；前 10 晋级；真机 6 任务；决赛 9.22–9.23。
- 评测方式：公网 WebSocket Policy Server，1–8 端点（host+port），策略名仅字母/数字/下划线，动作类型 ee/joint。
- 后端接口 `POST /api/v1/goai/simulation-applications/`，负载含 `policy_server_urls` 数组（前端拼为 `ws://host:port`）。
- 赛程（AOE）：报名 7.16；初赛 7.16–8.20；评审 8.21–8.23。
- 数据仓库：`https://huggingface.co/datasets/RoboDojo-Benchmark/GOAI-2026`。
- XPolicyLab 指引 `XPolicyLab/policy/YOUR_POLICY`；“已集成 30 余个 baseline”。
- 奖项：GOAI 大奖 ¥1,000,000 ×1；冠军 ¥250,000 ×2；亚军 ¥150,000 ×2；季军 ¥50,000 ×2；另设专项奖。主办：杭州市开源人工智能基金会。

## VERIFIED_XEVAL_GENERAL（仅 X-Eval 通用产品页，非 GOAI 规则）

- 50 任务排行榜：Overall = 40% Clean SR + 60% Randomized SR；Retention = Randomized ÷ Clean；示例 11 policies，更新于 2026.07.22。

## INFERENCE

- 前端代码生成 `ws://` 而指南文字写 `wss://` → 门户接受 ws/wss 文本；是否强制 TLS 需组委会确认。

## UNKNOWN

- GOAI 正式评分公式、episode 数、超时/并发/消息大小限制、端点语义、ensemble/外部 API 规则、结果回传内容（完整清单见 goai_submission_contract.md）。
