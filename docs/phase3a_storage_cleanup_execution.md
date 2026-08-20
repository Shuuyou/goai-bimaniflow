# Phase 3A-SC：构建缓存定向清理执行报告（历史存档）

日期：2026-08-12（执行窗口 20:51–21:10 +0800）。

## 人工批准范围

仅清理本次 RoboDojo 两次构建产生、已归因为本项目的 47 条 BuildKit cache（约 75.4 GB）。

## 批准清单

- 47 条完整 ID（logs/phase3a/approved_cache_ids.txt），sha256：`1681f57a0c29e401bf986c7040006e15a53995e70f0e7aea8bcfe58f2df7d69b`
- 核验：47/47 全部存在于当前 buildx du；总量 75.45 GB（偏差 0.05 GB，未触发 INVENTORY_DRIFT）

## 定向语义核验

- buildx v0.35.0；`--filter id=<cache-id>` 经只读 du 实证精确匹配单条记录 → 支持按 ID 定向。

## 执行与结果

- 对 16 条执行逐条定向 prune（全部 exit 0）；**实际删除 4 条**：3w2na02c0r5s…（2.784 GB）、r99otnjmib1e…（388.8 MB）、4wzco3on2sv0…（16.38 kB）、kqto8ndnvsax…（8.192 kB）。
- **实际释放总量：约 3.2 GB**；根分区 148–149 → 151 GB。
- 43 条未处理：36 条 shared=true（与目标镜像共享内容 blob，受镜像引用保护，定向 prune 返回 0B）；其余 daemon usage count 保护。
- 未发生 FILTER_EFFECT_MISMATCH / UNAPPROVED_CACHE_REMOVAL / TARGET_IMAGE_INTEGRITY_FAILURE；未批准 cache 抽查全部存在；目标镜像 ID 不变；运行中容器/镜像/卷完全一致；零 GPU 任务。

## 结论与修正

批准口径 75.4 GB 中 94%（70.94 GB）与目标镜像共享内容，镜像存续期间不可释放——修正了归因文档中“删 cache 释放 75.4 GB”的预估。在“不删镜像、不用全局 prune”约束下无法达到 200/220 GB。

## 后记（2026-08-16）

阻断最终由用户人工扩容解除（根分区整理至 ~254 GB + 新 ext4 /data 1.7 TB）→ STORAGE_GATE_PASSED。
