# 许可证审计（工程合规，非法律意见）

日期：2026-08-12。代码、数据、资产、权重分开记录。

## 代码

| 组件 | License | 证据 | 风险 |
|---|---|---|---|
| RoboDojo | **CONFLICT**：`LICENSE` 文件全文为 MIT；但 README:129 声明 “RoboDojo Non-Commercial Research License”，badge 标 Non-Commercial；pyproject.toml 写 MIT | third_party/RoboDojo/LICENSE；README.md:129,136 | **中**：文本与声明矛盾，按更严格者（NC）对待，需向维护者求证 |
| XPolicyLab | Apache-2.0 | XPolicyLab/LICENSE | 低 |
| IsaacLab（fork） | BSD-3-Clause | third_party/IsaacLab/LICENSE | 低 |
| curobo（fork） | Apache-2.0（资产另列 LICENSE_ASSETS） | third_party/curobo/LICENSE* | 低 |
| Isaac Sim 5.1 | NVIDIA 专有许可（pip 发行） | Dockerfile:33 | 低-中（不可再分发其运行库） |
| 各 baseline adapter | 各 policy 目录可能自带 LICENSE；上游模型代码各自许可（ACT=MIT，DP=MIT，OpenVLA=MIT，openpi=Apache-2.0 等） | policy/<P>/ | UNKNOWN（未逐一点验 42 个 policy） |

## 数据 / 资产 / 权重

| 项 | License | 风险 |
|---|---|---|
| GOAI-2026 数据集（HF） | **UNKNOWN**（无 LICENSE 标签、根 README 缺失） | **中**：赛事语境下使用属预期行为，但**不得再分发数据**；需组委会确认 |
| Assets/**（任务资产） | UNKNOWN（随数据集仓库） | 同上 |
| 官方 baseline checkpoint | UNKNOWN（仓库未标注） | 使用待确认，不再分发 |
| 上游预训练权重 | 各自上游许可（OpenVLA=MIT、GR00T=NVIDIA Open Model License 等） | 中：逐案核对 |

## 结论

- 参赛使用：RoboDojo/XPolicyLab/IsaacLab/curobo 均不阻碍（RoboDojo 按 NC 对待）。
- 开源衍生代码（本项目）：可基于 Apache/BSD/MIT 部分自由开源；**禁止将 RoboDojo 代码或官方数据/权重再分发进本仓库**。
- 数据与权重一律不再分发；权重引用以官方下载脚本为准。
- 待确认：RoboDojo LICENSE 文本 vs 声明矛盾；GOAI-2026 数据集许可。
