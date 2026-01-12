# qingbaoju-bot
一款自动跟随聚合群KOL策略的自动化程序

:ADITHYANGAMINGemojis: 面向普通用户的一键部署方案：监听 Discord 交易信号，自动在币安模拟交易合约下单，附带可视化前端（`/frontend/`）配置与查看状态。

## :star:主要特点
- 前端配置：通过页面填写 Discord Token、Binance API Key/Secret，新增频道即可使用。
- 多入场/多止盈：自动根据风险金额计算仓位，创建止盈止损单。
- 实时状态：订单/日志/历史盈亏在前端可查。
- 数据持久化：配置、数据库、日志全部挂载到宿主机，容器重建不丢数据。
- 敏感数据本地化存储

## :zap:快速部署（Docker，amd64）
前提：放行 8000 端口。

### 首次部署

### 0) 安装 Docker
Debian 复制整段执行：
```bash
curl -fsSL https://get.docker.com | sh
sudo systemctl enable --now docker
docker version
```

1) 拉取镜像  
```bash
docker pull zhousir11/discord-follower:amd64-V1.5
```

2) 准备宿主机数据目录  
```bash
mkdir -p /opt/discord-follower/data/logs
touch /opt/discord-follower/data/config_store.json
touch /opt/discord-follower/data/binance_follower.db
```

3) 启动容器  
```bash
 docker run -d --name discord-follower \
   -p 8000:8000 \
   -v /opt/discord-follower/data/config_store.json:/app/config_store.json \
   -v /opt/discord-follower/data/binance_follower.db:/app/binance_follower.db \
   -v /opt/discord-follower/data/logs:/app/logs \
   zhousir11/discord-follower:amd64-V1.5
```

4) 打开前端  
- 浏览器访问 `http://服务器IP:8000`进行登录。
- 初始账户：admin
- 初始密码：admin


## :recycle:更新程序容器

- 无需重新创建数据文件夹/配置/数据库，继续挂载原来的 `/opt/discord-follower/data/`。
- 步骤：
  ```bash
  docker rm -f discord-follower 2>/dev/null   #删除并停止旧程序
  docker pull zhousir11/discord-follower:amd64-V1.5  #拉取新容器
  docker run -d --name discord-follower \
    -p 8000:8000 \
    -v /opt/discord-follower/data/config_store.json:/app/config_store.json \
    -v /opt/discord-follower/data/binance_follower.db:/app/binance_follower.db \
    -v /opt/discord-follower/data/logs:/app/logs \
    zhousir11/discord-follower:amd64-V1.5
  ```
- 启动后刷新前端（Ctrl+Shift+R）确保样式与接口更新生效。

## :scroll:重置密码

- 在服务器上运行 
```bash
docker exec -it discord-follower python3 reset_password.py
```
可一键重置为默认帐户：admin 默认密码：admin

## :green_book:使用步骤（前端）
1) 交易配置  
   - 填写 Discord Token。  
   - 填写 Binance API Key/Secret（测试网/实盘各自一组），开启对应开关连接。建议先测试网。
2) 新增频道  
   - 选择交易员（列表来自内置的 `trader_channels.json` 映射）。  
   - 填风险金额、交易所（binance）、模式（testnet/live）、备注，启用保存。  
3) 日志查看  
   - 前端“日志查看”页实时显示程序日志；也可 `docker logs -f discord-follower` 查看容器日志。  
4) 历史数据  
   - 查看已平仓/取消订单的盈亏、手续费等；可按模式、交易员筛选。
5) 安全设置
   - 首次登录后修改初始密码以保护程序安全性，如果忘记密码可以通过命令重置为默认帐密（admin/admin）

## :question:常见问题
- 网页无法打开：检查云安全组/防火墙放行 8000。  
- 交易员列表为空：确认容器内 `trader_channels.json` 存在且 JSON 格式正确。
- 下单失败：检查账户是否开启双向持仓模式 和关闭统一账户
- 杠杆设置：程序在连接交易所时会统一设置所有交易对为最大杠杆，所以建议使用子账户连接。
- 风险金额：程序自动通过入场价和止损价及设置的风险金额计算仓位大小，例如风险金额为30U,仓位大小的计算公式为：30/(入场价-止损价)
- 日志中DC断开连接：日志显示"Discord临时断开连接（将自动重连）"不用理会，此为正常现象。
- 手动在交易所平仓程序未同步：交易所中平仓程序无法同步，所以建议各位使用子账户，在程序中手动平仓，交易所可以同步。
- 手机访问前端：UI还未适配手机界面，使用手机浏览器访问前端UI会变形，建议切换到桌面版显示模式。
- 程序前端与交易所未实现盈亏不一致：现在计算盈亏是以策略入场价进行计算，而不是以实际入场价计算，以交易所为准
- 忘记登录密码：在宿主机运行 `docker exec -it discord-follower python3 reset_password.py` 可一键重置为默认密码（admin/admin）


## :arrows_counterclockwise:更新日志
-  2026-01-10发布V1.5版本
- 新增 The Lab 分类交易员信号解析器
- 已实现盈亏改为通过实际仓位计算，不再以币安反馈的盈亏记录，这样对于多个交易员开了同币种同方向的订单计算更准确，不会因为交易所合并订单导致入场价被平均。
- 新增频道中选择交易员有一些小BUG，选中交易员不会显示名字，不影响使用，下个版本一并解决
- 修复了chroma个别交易更新信号的识别逻辑。


## :exclamation:风险提示
本程序仅允许模拟跟单交易，辅助统计交易员胜率，加密货币交易涉及重大风险请谨慎操作

## :bell:免责声明
本程序含有实盘交易接口主要为作者本人自用，分享本程序主要为让各位通过模拟交易统计交易员胜率，如若开启实盘风险自担。

@everyone
