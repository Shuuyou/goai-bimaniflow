# Gate B2/B3：ACT push_T checkpoint 元数据与下载记录

日期：2026-08-17。

## 来源核验

- 仓库：`RoboDojo-Benchmark/RoboDojo`，**dataset** 类型。
- revision/HEAD sha：`abf44de4b10b5c7efdc68f07630157329dbbcb7f`（lastModified 2026-08-06）。
- License：仓库标签 `license:apache-2.0`。
- 精确路径：`ckpt/RoboDojo/ACT/act-RoboDojo-push_T/arx_x5-100-joint`（名称显式标注 arx_x5 / 100 episodes / joint）。
- ACT 目录下另有 35 个任务目录（不下载）。

## 文件清单

| 文件 | 大小 | LFS oid (前16) | lastCommit |
|---|---|---|---|
| dataset_stats.pkl | 44,209 B | 642f47f1f4052a9e | 2026-07-13 |
| policy_epoch_6000_seed_0.ckpt | 335,912,094 B | d41ea255207ceea1 | 2026-07-13 |
| policy_epoch_6000_seed_1.ckpt | 335,912,094 B | 070e6ccacf2e74cc | 2026-07-13 |
| policy_epoch_6000_seed_2.ckpt | 335,912,094 B | db3017ca905bc846 | 2026-07-13 |
| **合计** | **961.1 MB** | | |

- 校验：HF LFS oid 即 sha256，下载后逐文件核验通过（4/4）。
- 无 README/训练参数文件。
- embodiment：arx_x5（=dual_x5 本体）；action type：joint。
- 加载方式：官方 `ACT.load_state_dict(torch.load(policy_last.ckpt))`（strict 默认 True）。

## Gate B3 下载记录（2026-08-17）

- 命令：snapshot_download(repo=RoboDojo-Benchmark/RoboDojo, revision=abf44de4, allow_patterns=["ckpt/RoboDojo/ACT/act-RoboDojo-push_T/**"], local_dir=/data/goai-bimaniflow/models/ACT/push_T)，HF_HOME 指向数据分区（EXIT=0，4 文件 53 秒）。
- 落盘：961.1 MB，仅 push_T 目录；未触碰其他任务/HDF5/LeRobot。
- 校验：4/4 文件 sha256 与官方 LFS oid 完全一致。
- 后续安排：创建 `policy_last.ckpt -> policy_epoch_6000_seed_0.ckpt` 符号链接。
- 下载方式：hf_hub HTTP。
