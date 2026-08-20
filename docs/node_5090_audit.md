# 5090 节点审计（Phase 0R）

审计日期：2026-08-12。所有事实来自本机只读命令输出。

## 系统

| 项 | 值 | 来源 |
|---|---|---|
| 主机名 | Baiyang-5090-1 | `uname -a` / `docker info` |
| OS | Ubuntu 24.04.4 LTS (Noble) | `/etc/os-release` |
| 内核 | 6.14.0-37-generic | `uname -a` |
| CPU | Intel Core i9-14900K，24 核 32 线程，VT-x | `lscpu` |
| 内存 | 62 GiB 总量；swap 8 GiB | `free -h` |

## GPU

| 项 | 值 |
|---|---|
| GPU | 1 × NVIDIA GeForce RTX 5090（Blackwell 消费级，sm_120） |
| 显存 | 32607 MiB |
| 驱动 | 590.48.01 |
| nvidia-smi CUDA 支持上限 | CUDA 13.1（**仅为驱动支持上限，不是已安装 CUDA toolkit**） |
| 拓扑 | 单卡，CPU Affinity 0-31 |

## Docker

| 项 | 值 |
|---|---|
| Docker Engine | 29.6.1（client + server 均正常） |
| Compose | v5.3.1 |
| Storage Driver | overlayfs（containerd snapshotter） |
| Docker Root Dir | `/var/lib/docker`（根分区） |
| 镜像账面占用 | 247 GB（43 个） |
| 容器账面占用 | 27.49 GB（37 个） |
| 卷账面占用 | 30.11 GB（42 个） |
| Build Cache | 258.3 GB（其他项目，禁止清理） |
| NVIDIA Container Toolkit | nvidia-ctk 1.19.0；CDI 已发现 nvidia.com/gpu；runtime `nvidia` 已注册 |

## 用户与权限

- uid=1001(cpc)，组：sudo, docker, video 等。本项目所有操作以普通用户完成，不使用 sudo。
- conda 26.1.1，git 2.43.0，git-lfs 3.4.1。

## 存储

| 挂载点 | 文件系统 | 容量 | 可用 |
|---|---|---|---|
| `/`（/dev/sda4） | ext4 | 2.7 TB | **251 GB（91% 已用）** |
| 数据分区 | 当时为 fuseblk（NTFS/FUSE） | 2.8 TB | 2.7 TB |

## 是否适合作为唯一主节点

适合，附带条件：CPU/内存/单卡 5090 足以承担 baseline 训练、本地仿真自测与 Policy Server；根分区紧张需严控 Docker 体积；GPU 上既有负载需避让。

## 后续

2026-08-16 用户人工扩容：根分区 ~254 GB，新 ext4 分区 /data 1.7 TB → STORAGE_GATE_PASSED（见 decision_log #17-18）。
