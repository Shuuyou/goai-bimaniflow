# Phase 4A-Preflight：公网条件只读审计

日期：2026-08-19。全部只读；未启动任何公网监听；未读取任何私钥。

## 事实

1. **本机网卡**：有线/无线/tailscale0 均为私网地址。无公网地址直接绑定。
2. **NAT**：是，位于家用/实验室路由器后。
3. **公网 IPv4**：无（本机层面）。**公网 IPv6**：无全局地址。
4. **出站互联网**：可用但有按主机过滤迹象（huggingface.co 200；个别 IP 查询服务超时）。
5. **既有 Tailscale Funnel**：`https://baiyang-5090-1.tailcdb222.ts.net` → `http://127.0.0.1:3000`（TLS 由 Tailscale 托管）。当时节点 tailnet 连通性存疑，且 127.0.0.1:3000 当时无监听。
6. **80/443 占用**：公网网卡上 80 空闲；443 仅绑定在 tailscale 接口。0.0.0.0:8443 与 0.0.0.0:19091 被其他项目占用（不触碰）。
7. **既有反向代理**：无 nginx/caddy/traefik；唯一受控网关是 Tailscale serve/funnel。
8. **既有 TLS 证书**：无 /etc/letsencrypt；未发现用户证书目录。
9. **Docker 网络**：多个 bridge 网络存在，均不影响本方案（策略服务走 host loopback）。

## 结论回答

1. 公网 IPv4：**无**（本机）；2. 公网 IPv6：**无**；3. NAT 后：**是**；4. 已知可用域名：**有候选** `baiyang-5090-1.tailcdb222.ts.net`（Tailscale 托管 TLS；作为 GOAI 正式端点的可接受性需用户确认）；5. 80/443：公网网卡空闲，tailscale 接口 443 被 funnel 自身占用；6. 现有反向代理：Tailscale funnel；7. 接入现有代理：可以，需用户确认 funnel 目标端口无其他用途；8. 当前用户可部署反向代理配置：UNKNOWN；9. 现成 TLS 证书：无（Tailscale 路径则不需要本地证书）；10. 需人工 DNS：Tailscale 路径不需要；自有域名路径需要；11. 需人工端口转发：路由器路径需要；12. 需实验室管理员：路由器/防火墙路径需要；13. 能否满足 wss://host:port：Tailscale funnel 固定走 443；14. **最小必要人工输入**（三选一）：(a) 批准使用既有 Tailscale Funnel 域名；(b) 自有域名 + DNS + 路由器端口转发；(c) 有公网 IP 的受控云主机做反向中转。

## 状态与后续

当时状态：**PLAN_READY_NEEDS_NETWORK_INPUT**。
后续（2026-08-20）：Funnel 公网 TLS 经重声明与重注册仍不通（判定 tailnet 账户/签发层故障），弃用；改走 (c) 云主机中转——详见 phase4a_external_connectivity.md 与 decision_log #30。
