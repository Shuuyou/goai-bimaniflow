# Phase 3A 官方镜像构建审计与记录

## 步骤 C：构建入口审计（third_party/RoboDojo @ 36bfcb7）

1. **FROM**：`nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04`（Dockerfile:22，公开 Docker Hub 镜像）。
2. **是否下载 Isaac Sim**：是，pip `isaacsim[all,extscache]==5.1.0`（Dockerfile:156，pypi.nvidia.com 公开源）。
3. **是否运行 install.sh**：否。Dockerfile 内联复刻 install.sh 步骤（注释明示），不在宿主执行 `scripts/install.sh -i`；其副作用全部限定在镜像层。
4. **是否写入模型或数据**：否。`.dockerignore` 排除 Assets/、checkpoints/、*.pt/*.safetensors 等；镜像明确“no policy, no checkpoints”。
5. **NGC 登录**：不需要。
6. **GitHub/HF Token**：不需要（子模块已随克隆进入构建上下文）。
7. **预计镜像层大小**：基础镜像 ~14 GB + Isaac Sim pip 栈 ~20–40 GB + torch cu128 ~3.5 GB + curobo/IsaacLab 编译层；官方口径“最大约 200 GB（含全部扩展缓存）”。估 40–80 GB，构建后实测。
8. **RTX 5090 支持**：torch 2.7.0+cu128 支持 sm_120；`TORCH_CUDA_ARCH_LIST` 不含 12.0（curobo 编译风险，见 rtx5090_compatibility.md）。
9. **EGL/Vulkan**：是。镜像烘焙 NVIDIA EGL vendor JSON + 单 Vulkan ICD 锁定（Dockerfile:99-117, 219-220）。
10. **curobo 编译**：是。`pip install -e ".[cu12]" --no-build-isolation`（Dockerfile:169-171）。

结论：无私有凭据需求；最大不可估算项为 Isaac Sim pip 下载（~20 GB 级，公开源）→ 允许构建。

## 步骤 D：构建策略

- 无官方预构建镜像（全仓库无 ghcr/registry 发布引用）→ 采用官方 Dockerfile 原样构建，不改上游。
- 标签：`goai-bimaniflow/robodojo:36bfcb7`。
- 命令：`docker build --progress=plain -t goai-bimaniflow/robodojo:36bfcb7 .`（不用 --no-cache；不动共享 cache）。
- 完整日志：logs/phase3a/docker_build.log。

## 构建记录

- 2026-08-12 首次构建：在 Dockerfile:153（torch cu128）因构建容器内 `download.pytorch.org` DNS 解析瞬态失败而中止（宿主同域 curl 200，确认为容器 DNS 路径问题）。失败后根分区 231 GB，仍 ≥200 GB。
- 针对性重试（本阶段唯一一次）：`docker build --network=host`（构建容器直接使用宿主网络栈，不修改任何系统/daemon 配置）。
- 缓存实际情况（修正旧表述“缓存层全部复用”）：基础镜像拉取层与非 RUN 层复用；`--network=host` 将网络模式计入 BuildKit 缓存键，联网 RUN 层自 apt 起重新执行；torch 与 Isaac Sim 相关层首次构建从未成功，没有完整缓存可复用。
- PROCESS_DEVIATION_ASSET_DOWNLOADED_BEFORE_GATES：步骤 H/I（push_T 选择与 424 MB 资产下载）于 2026-08-12 在构建与探针闸门之前执行，违反阶段顺序。资产来源 GOAI-2026 @ 8ca75af，清单 logs/phase3a/asset_manifest{,_sha256}.txt，未运行、未启动仿真。纠正：保留资产、停止进一步下载、不删除重复下载，后续步骤等待构建审计与人工闸门。详见 docs/decision_log.md 第 14 条。

## 构建结果审计（retry1 退出后，2026-08-12）

- 构建结果：**成功**。日志结尾 `#32 naming to docker.io/goai-bimaniflow/robodojo:36bfcb7`、`unpacking ... DONE`；镜像已生成并打标签。（后台任务句柄丢失（lost），以日志完整完成 + 镜像存在为成功证据；构建总耗时约 67 分钟。）
- Image ID / digest：`sha256:cc083b0887ecc49f721c8c81bae4821e36355291c7acce2d43dee1e30d3c7c6a`
- Created：2026-08-12T07:20:45（+08:00）；Architecture：amd64/linux
- 大小：26.6 GB（inspect Size=26,631,718,486；`docker image ls` 显示 70.9 GB 为含共享层的口径）——远好于官方“最大 ~200 GB”上限口径。
- 镜像内版本：Python 3.11.15；torch 2.7.0+cu128（CUDA 12.8）；warp 1.11.0；numpy 1.26.0；websockets 12.0；**curobo import OK**（源码编译在构建期成功完成）。
- `pip check`（exit 1）：8 项版本冲突，全部源于官方 Dockerfile 的刻意 repin（packaging 23.0、websockets 12.0、typing_extensions 4.12.2、filelock 3.13.1、psutil 等）——属官方镜像既知状态，**按规则不修改任何依赖**。当前状态：PIP_CONFLICTS_PRESENT / KEY_IMPORTS_PASS / RUNTIME_IMPACT 部分已知 / NO_DEPENDENCY_CHANGES_ALLOWED_YET。
- 磁盘复核：根分区 **149 GB**（构建前 250 GB）。
- docker system df：Images 317.9 GB（44 个）；Containers 27.34 GB；Volumes 30.11 GB；Build Cache 333.7 GB。
- 无未标记中间镜像；无本项目容器残留。
- **红线判定：149 GB < 150 GB → BLOCKED_ROOT_STORAGE_POSTBUILD**（后续由用户人工扩容解除，见 decision_log #17-18）。
