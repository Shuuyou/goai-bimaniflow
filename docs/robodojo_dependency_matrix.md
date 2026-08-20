# RoboDojo 依赖矩阵（Dependency Matrix）

仓库：third_party/RoboDojo @ `36bfcb7c580b149c6e39ed2eb77d60689152e570`（main）。

| 组件 | 声明版本 | 证据（路径:行号） | 约束性质 |
|---|---|---|---|
| 基础镜像 | nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04 | Dockerfile:22 | 硬约束（Docker 路径） |
| Python | 3.11（conda env `RoboDojo`） | Dockerfile:136；install.sh:107 | 硬约束 |
| PyTorch | 2.7.0 + torchvision 0.22.0 + torchaudio 2.7.0，cu128 wheel | Dockerfile:154-155 | 硬约束 |
| Isaac Sim | 5.1.0（pip `isaacsim[all,extscache]`） | Dockerfile:156 | 硬约束 |
| Isaac Lab | vendored fork @ afca7b0（`--install none`） | Dockerfile:168 | 硬约束（锁定 commit） |
| curobo | vendored fork @ d17b54c（分支 isaacsim-warp18） | Dockerfile:169-171 | 硬约束（锁定 commit） |
| warp-lang | 1.11.0 | Dockerfile:179 | 硬约束（repin） |
| numpy | 1.26.0 | Dockerfile:149,153,172-173 | 硬约束 |
| scipy | 1.15.3 | Dockerfile:148,178 | 硬约束 |
| typing_extensions | 4.12.2 | Dockerfile:153,175 | 硬约束 |
| filelock | 3.13.1 | Dockerfile:153,176 | 硬约束 |
| websockets | 12.0 | Dockerfile:177 | 硬约束（**与 XPolicyLab>=14 要求冲突，策略服务须容器外运行**——decision_log#24） |
| opencv-python-headless | 4.11.0.86 | Dockerfile:148 | 硬约束 |
| TORCH_CUDA_ARCH_LIST | "7.0;7.5;8.0;8.6;8.9;9.0+PTX" | Dockerfile:40 | 构建期建议（不含 sm_120；curobo 实测编译运行通过） |
| Headless EGL/Vulkan | NVIDIA ICD 注入 + 单 Vulkan ICD 锁定 | Dockerfile:99-117,219-220 | 硬约束（headless RTX） |
| 评测通信 | Policy Server 在容器外经 TCP/WebSocket | Dockerfile:4-9；docker/README.md | 架构约束 |
| GOAI 评测机器人 | dual_x5（ARX X5 双臂，arm 6+6，ee 1+1） | env_cfg/robot/_robot_info.json | VERIFIED |
| 任务配置 | 12 base + 12 _random yml 均存在 | task/RoboDojo/config/ | VERIFIED |

## 宿主机已具备

Docker 29.6.1 + nvidia runtime + nvidia-ctk 1.19.0；驱动 590.48.01（满足 CUDA 12.8）；conda 26.1.1；git-lfs 3.4.1。
