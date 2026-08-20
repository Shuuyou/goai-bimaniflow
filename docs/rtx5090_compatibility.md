# RTX 5090 兼容性审计

日期：2026-08-12（静态）；2026-08-17 已全部实证（Phase 3A-R 闸门）。硬件：RTX 5090（Blackwell 消费级，**sm_120**），驱动 590.48.01。

| 检查项 | 结论 | 证据 |
|---|---|---|
| 驱动 vs CUDA 12.8 容器 | VERIFIED：满足（需 ≥570，实际 590.48.01） | nvidia-smi |
| torch 2.7.0+cu128 vs sm_120 | VERIFIED（静态）+ **实证 PASS**（Gate E1 matmul） | logs/phase3a_runtime/cuda_probe.log |
| TORCH_CUDA_ARCH_LIST 不含 sm_120 | 潜在风险 → **实证通过**：curobo 构建期编译成功，FK CUDA kernel 运行正常（Gate G1） | logs/phase3a_runtime/curobo_runtime_probe.log |
| Isaac Sim 5.1 vs RTX 50 系 | VERIFIED + **实证 PASS**（Gate F1 headless 启停） | logs/phase3a_runtime/isaac_headless_probe.log |
| warp-lang 1.11.0 | 支持 Blackwell；实证通过 | 同上 |
| “no kernel image” 风险 | 未发生（全链路实证） | — |
| 显存预算 | 32 GiB 总量；Isaac Sim + ACT 实测共 ~13 GB 峰值（含其他项目） | logs/phase3c/gpu_samples_*.txt |

## 结论

官方 cu128 + Isaac Sim 5.1 路线与 RTX 5090 无架构级冲突，全部风险项已通过运行实证关闭。冷启动注意：sm_120 首次 MDL/着色器编译约 20–36 分钟（单线程 CPU），复用缓存后回落。
