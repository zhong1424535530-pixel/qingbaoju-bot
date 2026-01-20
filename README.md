# 聚合群KOL策略自动交易系统
一款自动跟随聚合群KOL策略的自动化程序

面向普通用户的一键部署方案：监听 Discord 交易信号，自动在币安模拟交易合约下单，附带可视化前端配置与查看状态。

## :star:主要特点
- 前端配置：通过页面填写 Discord Token、Binance API Key/Secret，新增频道即可使用。
- 多入场/多止盈：自动根据风险金额计算仓位，创建止盈止损单。
- 实时状态：订单/日志/历史盈亏在前端可查，支持测试网与实盘切换。
- 数据持久化：配置、数据库、日志全部挂载到宿主机，容器重建不丢数据。

## :zap:快速部署（一键脚本）
**推荐方式**：复制下方命令在服务器执行，脚本会自动安装 Docker、准备目录并启动容器或删除旧程序容器运行新程序。

```bash
curl -O https://raw.githubusercontent.com/zhong1424535530-pixel/qingbaoju-bot/main/install.sh && chmod +x install.sh && ./install.sh
```
*(注：如果无法访问GitHub，请手动上传 `install.sh` 到服务器运行)*


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
-  2026-01-20发布V1.5.1版本
- 修复了一些已知BUG
- 增加了价格合理性验证逻辑：如果交易所发布的策略价格错误/不合理，程序会拒绝执行
- 增加了策略去重逻辑：如果交易员发布连续两条同样策略会拒绝执行第二条
- 增加了增加了adrikinez交易员的识别
- 改进了部署方式，减少了操作步骤，支持一键部署更新

## :exclamation:风险提示
本程序仅允许模拟跟单交易，辅助统计交易员胜率，加密货币交易涉及重大风险请谨慎操作

## :bell:免责声明
本程序含有实盘交易接口主要为作者本人自用，分享本程序主要为让各位通过模拟交易统计交易员胜率，如若开启实盘风险自担。

<img width="1478" height="731" alt="image" src="https://github.com/user-attachments/assets/8ac748c4-b8d0-452f-ba4f-ad6668854195" />
<img width="1485" height="728" alt="image" src="https://github.com/user-attachments/assets/6059e324-5ec9-472d-9847-d92ed7a0d39a" />
<img width="1487" height="713" alt="image" src="https://github.com/user-attachments/assets/c73b935e-fc65-4c88-85c3-7015f315ef20" />

