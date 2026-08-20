# 提交版本清单（ACT v1，不可变基线）

生成日期：2026-08-19。提交时间 / 申请编号 / X-Eval 结果：留空待人工。

## 代码与镜像

| 项 | 值 |
|---|---|
| 主项目 Git commit | 2a11c7d（test: screen ACT seeds and evaluate push_T random） |
| RoboDojo | 36bfcb7c580b149c6e39ed2eb77d60689152e570 |
| XPolicyLab | 432f82b1758c5b1202e42a3dfe014546dbc50871 |
| IsaacLab | afca7b09d60d8beb9c1cb28b43066499940b969b |
| cuRobo | d17b54ce32cba095c0b000c4c58777075d11de0e |
| Docker 镜像 | goai-bimaniflow/robodojo:36bfcb7 |
| 镜像 ID | sha256:cc083b0887ecc49f721c8c81bae4821e36355291c7acce2d43dee1e30d3c7c6a |

## 策略

| 项 | 值 |
|---|---|
| 策略 | 官方 ACT adapter（XPolicyLab/policy/ACT，未修改） |
| checkpoint | ckpt/RoboDojo/ACT/act-RoboDojo-push_T/arx_x5-100-joint（官方仓库 RoboDojo-Benchmark/RoboDojo @ abf44de4） |
| BEST_ACT_PUSH_T_SEED | 0 |
| 权重文件 | policy_epoch_6000_seed_0.ckpt（sha256 d41ea255207ceea13b7aa1707d073aae7c38d1b826b5f08b0d82588ad3c41b1a） |
| policy_last.ckpt | 本地 symlink → policy_epoch_6000_seed_0.ckpt |
| normalization | dataset_stats.pkl（sha256 642f47f1f4052a9e1ee4d7099e6a40edefc29320b1a4853ed0cc373cf5461806，未修改） |
| action_type | joint |
| action_dim | 14（左臂6+夹爪1+右臂6+夹爪1，夹爪索引 6/13） |
| chunk_size | 50 |
| temporal_agg | true（k=0.01） |
| 相机 | cam_head / cam_right_wrist / cam_left_wrist |
| embodiment | env_cfg=arx_x5（机器人 dual_x5） |

## 运行环境

| 项 | 值 |
|---|---|
| 策略环境 | bimaniflow-act（宿主 conda，独立于仿真镜像） |
| Python | 3.11 |
| PyTorch | 2.7.0+cu128 |
| CUDA | 12.8（wheel）/ 驱动 590.48.01 |
| websockets | 17.0.1 |
| Policy Server 入口 | `XPolicyLab/setup_policy_server.py --config_path XPolicyLab/policy/ACT/deploy.yml --overrides …` |
| 本地端口 | 127.0.0.1:6061（仅 loopback） |
| 公网入口 | ws://47.101.158.121:8443（Phase 4A-Deploy，2026-08-20） |

## 留空（人工/后续填写）

- 提交时间：
- 申请编号：
- X-Eval 结果：
