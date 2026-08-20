# 存储规划（Storage Plan）

日期：2026-08-12（布局变更 2026-08-16）。红线分开计算，文件系统容量不得相加。

## 最终布局（2026-08-16 人工扩容后）

- 代码/Git/Conda/Docker：根分区 /dev/sda4（ext4，~254 GB 可用）
- 大文件根：`/data/goai-bimaniflow`（/dev/sda5，ext4，~1.7 TB 可用）
  - datasets / assets / models / checkpoints / artifacts / logs
  - cache/{huggingface,modelscope,isaac,torch,curobo}
- /Windows11/D（fuseblk）既有内容保留不动，不再承担新角色

## 红线

- 根分区：运行期 ≥120 GB；构建前 ≥200 GB；预计跌破 150 GB → BLOCKED_ROOT_STORAGE
- /data：≥1 TB；跌破 → BLOCKED_DATA_STORAGE

## 事实来源约定

- 代码：`/home/cpc/projects/goai-bimaniflow`
- 第三方代码：`third_party/`（Git 忽略）
- 数据与资产：`/data/goai-bimaniflow/{datasets,assets}`
- 模型与 checkpoint：`/data/goai-bimaniflow/{models,checkpoints}`
- 视频/结果/大日志：`/data/goai-bimaniflow/{artifacts,logs}`
- 轻量实验元数据：主 Git 仓库内 JSON/CSV/Markdown

## 环境变量占位（.env.example，不含真实凭据）

```
GOAI_DATA_ROOT=/data/goai-bimaniflow/datasets
GOAI_ASSET_ROOT=/data/goai-bimaniflow/assets
BIMANIFLOW_MODEL_ROOT=/data/goai-bimaniflow/models
BIMANIFLOW_CHECKPOINT_ROOT=/data/goai-bimaniflow/checkpoints
BIMANIFLOW_ARTIFACT_ROOT=/data/goai-bimaniflow/artifacts
HF_HOME=/data/goai-bimaniflow/cache/huggingface
MODELSCOPE_CACHE=/data/goai-bimaniflow/cache/modelscope
TORCH_HOME=/data/goai-bimaniflow/cache/torch
CUDA_CACHE_PATH=/data/goai-bimaniflow/cache/curobo
OMNI_USER_DIR=/data/goai-bimaniflow/cache/isaac
```
