# Gate B4/B5：ACT 独立策略环境计划与执行记录

日期：2026-08-17。原则：仿真留在官方镜像；ACT Policy Server 在宿主独立 conda 环境；不修改 base、bimaniflow-demo、RoboDojo 镜像与任何锁定 commit。

## 计划

- 环境名：`bimaniflow-act`，Python 3.11（宿主 miniconda，Linux 原生文件系统）。
- 依据：XPolicyLab/policy/ACT/install.sh + detr -e + XPolicyLab -e。
- **唯一偏离（精确修复）**：install.sh 的 `torch==2.4.1`（PyPI 默认 cu121）不支持 sm_120 → 改用与仿真镜像同栈且 Gate E1 已实证的 `torch 2.7.0 + torchvision 0.22.0（cu128 wheel）`。其余包按 install.sh，加 XPolicyLab 运行必需 websockets>=14、msgpack、msgpack-numpy、pydantic。
- 预计磁盘新增 ≈8 GB（< 20 GB 上限）。
- 回滚方式：`conda env remove -n bimaniflow-act`（环境独立，删除即完全回滚）。
- RTX 5090：torch 2.7.0+cu128 已实证 sm_120；ACT 无自定义 CUDA kernel，纯 cuBLAS/cuDNN 路径。

## 执行记录

- 执行结果（2026-08-17）：bimaniflow-act 创建成功；DEPS/DETR/XPL 全部 exit 0；detr 与 xpolicylab editable；包清单 logs/phase3b/act_environment_packages.txt（93 个）；**pip check 无冲突**；numpy 固定 1.26.4。
- 验证：torch 识别 RTX 5090 (12,0)，CUDA matmul OK；ACT 模型结构构建成功（83,897,487 参数，~84M）；ACT_ACTION_DIM=14 由官方 setup 脚本方式导出；torchvision 自动下载 ResNet18 ImageNet backbone（44.7MB，官方行为）。
