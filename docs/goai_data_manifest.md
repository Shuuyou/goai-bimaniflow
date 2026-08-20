# GOAI 数据清单（Data Manifest）

仓库：`RoboDojo-Benchmark/GOAI-2026`（连字符，已逐字符核对）。方法：仅 GET 元数据（HF datasets API + tree API），未下载任何文件本体。

- commit SHA：`8ca75af1ff79c30c4b9fbc552b99bac206bc014d`（lastModified 2026-08-05）
- 文件总数：**15,445**
- 总大小：**约 256.9 GB**
- License：**UNKNOWN**（无 license 标签，根 README.md 缺失）
- 存储后端：标准 LFS 规则；9,926 个文件带 lfs 标记。Xet 使用情况 UNKNOWN。
- 下载能力：`hf download --repo-type dataset --include/--exclude`；ModelScope 同名镜像。

## 顶层结构

| 路径 | 文件数 | 大小 |
|---|---|---|
| `Assets/` | 10,266 | **32.71 GB** |
| `data/` | 5,178 | **224.20 GB** |

## Assets 细分

| 子目录 | 大小 | 文件数 |
|---|---|---|
| Assets/Material | 24.28 GB | 2,980 |
| Assets/Object | 6.66 GB | 2,332 |
| Assets/Room | 1.58 GB | 1,932 |
| Assets/Robots | 0.12 GB | 118 |
| Assets/Eval_Layout | 0.03 GB | 2,895 |
| Assets/Sensor | 0.03 GB | 8 |
| Assets/Background | 0.02 GB | 1 |

最大文件为 Assets/Material 的 4K 法线贴图（单文件最大 423 MB）。

## data/hdf5（演示数据，arx_x5 本体）

| 任务 | episode 数 | 大小 |
|---|---|---|
| arrange_largest_number | 100 | 15.19 GB |
| fold_clothes | 100 | 10.20 GB |
| hang_mugs | 100 | 13.32 GB |
| make_toast | 100 | 19.31 GB |
| pack_objects_into_box | 100 | 20.77 GB |
| pour_liquid_into_cup | 100 | 5.55 GB |
| push_T | 100 | 7.42 GB |
| sort_nesting_dolls_by_size | 100 | 15.37 GB |
| stack_blocks | 100 | 6.11 GB |
| stack_bowls | 100 | 12.02 GB |
| store_laptop_and_headphones | 100 | 13.70 GB |
| sweep_blocks | 100 | 14.99 GB |
| **合计** | **1200** | **154.76 GB** |

路径模式：`data/hdf5/<task>/arx_x5/data/episode_XXXXXXX.hdf5`。单 episode 最大 378 MB（make_toast）。

## data/lerobot（LeRobot v3.0 格式）

| 路径 | 大小 | 文件数 |
|---|---|---|
| data/lerobot_v30_joint | 34.72 GB | 189 |
| data/lerobot_v30_ee | 34.72 GB | 189 |

## 任务→资产依赖映射

**UNKNOWN**：精确依赖闭包无法从公开元数据确定（任务 yml 引用类别名而非文件清单）；实操中通过预生成布局 JSON（Assets/Eval_Layout）逐任务推导已验证可行（Phase 3C-R）。

## random 配置资产

`_random` 配置使用相同 Assets 树 + 预生成布局内的差异化 Room/Table/Ground 材质（3C-R 实证），**不需要额外对象资产**。
