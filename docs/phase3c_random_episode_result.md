# Phase 3C-R：push_T_random 单 episode 结果（single-episode smoke result）

日期：2026-08-18。策略：官方 ACT push_T checkpoint seed_0（BEST_ACT_PUSH_T_SEED=0，sha256 d41ea255…）。**非正式成绩。**

## 新增资产

- 第一轮：13 个 clutter 对象 + clutter.yml + 30 个 seed-0 布局 = 29 文件 / **124.8 MB**
- 第二轮（补齐布局差异化场景）：Simple_Room_teal（115.3 MB）、material_0061（25.9 MB）、material_0418（9.5 MB）= 146 文件 / **150.7 MB**
- **合计新增 275.5 MB**；revision 8ca75af 锁定；根分区零新增。
- run#1 因场景资产缺失崩溃（TypeError: NoneType item assignment @ select_room/load_object_metadata），属基础设施失败；补齐后 run#2（唯一一次精确重试）通过。

## Random episode（run#2）

- 命令：同 clean 协议，仅 `--task push_T_random`；eval-num 1。
- **结果：600/600 步正常结束，exit 0；success=false；success_rate=0.0**（layout_id 0）。
- 结果/视频：eval_result/RoboDojo/push_T_random/ACT/.../2026-08-18_05-24-57/（_result.json + 3 路 601 帧视频）。
- 推理延迟：同栈稳态参考 P50 22.8 / P95 24.9 / P99 25.7 ms。
- GPU：整机峰值 23,512 MiB（其他项目 ~10.6 GB + ACT 4.0 GB + 仿真 ~9 GB）；无 OOM。

## Random vs Clean 行为差异（QUALITATIVE，视频证据）

| 维度 | clean（seed_0） | random（seed_0） |
|---|---|---|
| 场景 | 空桌 + T + 目标垫 | 13 个干扰物 + teal 房间 + 不同桌面/地面材质 |
| 机械臂运动 | 大幅、持续，接近并接触 T | 有运动，幅度更小、更犹豫 |
| 物体位移 | 有（T 离开原位） | 未见 |
| 目标垫到达 | 否 | 否 |
| 任务进展 | 有（接触+位移） | 基本无（APPROACH_FAILED，QUALITATIVE） |

结论：干扰物 + 视觉域偏移下，该 checkpoint 行为退化但未崩溃——仍输出合法动作、协议完整、600 步跑完；任务进展未保持。单 episode 不构成泛化结论。
