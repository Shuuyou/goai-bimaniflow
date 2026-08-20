# 最小任务选择（Phase 3A 步骤 H）

日期：2026-08-12。方法：纯静态分析（task 配置/代码 + GOAI-2026 tree 元数据 sha 8ca75af），未运行仿真、未试错下载。本体统一为 arx_x5 双臂（dual_x5）。

## 12 任务对比

| 任务 | 物理类型 | 任务特有物体资产 | config 行数 | 排除理由 |
|---|---|---|---|---|
| fold_clothes | **布料** | clothes | 18 | 布料模拟 |
| pour_liquid_into_cup | **流体** | cup 等 | 63 | 流体 |
| make_toast | 铰接 toaster + 状态变化 | toaster 等 | 115 | 铰接+烹饪状态 |
| store_laptop_and_headphones | 铰接 laptop | laptop 等 | 92 | 铰接对象 |
| pack_objects_into_box | 刚体 | box + 多物体 | 90 | 物体多 |
| sort_nesting_dolls_by_size | 刚体（嵌套） | matryoshka 707.8 MB | 45 | 资产最大 |
| arrange_largest_number | 刚体 | number 216 MB | 53 | 9 物体层级选择 |
| hang_mugs | 刚体 | mug 436.4 MB | 39 | 资产较大 |
| stack_blocks | 刚体 | block 213.3 MB | 32 | 资产较大 |
| sweep_blocks | 刚体 | broom + blocks | 55 | 工具使用 |
| stack_bowls | 刚体 | bowl 242.1 MB | 16 | 资产 242 MB |
| **push_T** | 刚体 | **t ≈0.03 MB + t_cushion ≈0.07 MB** | 36 | **当选** |

## 最终选择：`push_T`（基础配置）

满足全部条件：无流体、无布料/软体、无铰接、无状态变化；任务特有资产 < 1 MB（12 任务中最少）；场景初始化仅 1 个 t 块 + 1 个目标垫；成功判定简单（is_qpos_close + xy 距离 + 回原点）；demo_policy 返回合法零动作即可走完协议。

## 所需资产闭包（静态推导）

| 路径（GOAI-2026 仓库内） | 大小 |
|---|---|
| Assets/Room/Simple_Room_nolight/ | 115.3 MB |
| Assets/Material/material_0122/ | 16.8 MB |
| Assets/Material/material_0564/ | 127.3 MB |
| Assets/Background/brown_photostudio_02_4k.hdr | 24.3 MB |
| Assets/Sensor/ | 26.2 MB |
| Assets/Object/RoboDojo/Geometry/camera_stand/ | ~0.1 MB |
| Assets/Object/RoboDojo/Geometry/t_cushion/ | 0.07 MB |
| Assets/Object/RoboDojo/Rigid/t/ | 0.03 MB |
| Assets/Robots/x5/ | 104.6 MB |
| Assets/Eval_Layout/RoboDojo/arx_x5/0/push_T_*.json | 1.84 MB |
| **合计** | **≈ 417 MB** |

注：闭包推导必须覆盖布局 JSON 的 Room/Table/Ground/Background 段（3C-R 实证教训）。
