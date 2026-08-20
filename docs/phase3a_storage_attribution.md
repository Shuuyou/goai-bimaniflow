# Phase 3A-S：Docker 存储归因（只读分析，历史存档）

日期：2026-08-12。全部操作为只读元数据查询。注：该阻塞随后由用户人工扩容解除（2026-08-16，decision_log #17-18）。

## 总量快照

| 项 | 值 |
|---|---|
| 根分区 | 149 GB 可用，构建前 250 GB → 变化约 101 GB |
| Docker Images | 44 个，账面 317.9 GB |
| Containers | 23 个，27.34 GB |
| Volumes | 42 个，30.11 GB |
| Build Cache | 773 条，333.7 GB（Shared 247.7 / Private 86.01） |
| Dangling images | 0 个 |

## 构建增长归因

| 归因 | 大小 | 证据 |
|---|---|---|
| 最终镜像独占层 | ~26.6 GB | inspect Size=26,631,718,486 |
| 本项目两次构建的 BuildKit cache | ~75.4 GB（47 条，last accessed ≤9h） | buildx_du 按时间筛选 |
| 合计 ≈102 GB，与实测 101 GB 变化吻合 | — | — |
| 首次失败构建 vs retry1 细分 | 无法精确区分 | UNKNOWN_CACHE_OWNERSHIP |
| 其他项目 cache（构建前已存在） | 258.3 GB | 与构建前账面精确吻合 |

## 关键事实（步骤 F）

1. inspect Size 26.6 GB 与 image ls 70.9 GB 的口径差异 = 共享基础层 + 与 cache 共享的 ~44 GB blob。
2. 101 GB 增长主要来源：~75.4 GB BuildKit cache + ~26.6 GB 镜像。
3. 目标镜像不依赖 cache（层已固化在内容存储）；删除 cache 不影响镜像，仅拖慢重建。
4. 结论：可安全审核候选 ≥50 GB 存在（本项目 cache 75.4 GB），但默认 docker driver 下无按单条 ID 删除的合法非 prune 命令。

（清理执行结果见 phase3a_storage_cleanup_execution.md：实际仅 4 条可删、释放 3.2 GB，其余 70.94 GB 与镜像共享内容不可释放。）
