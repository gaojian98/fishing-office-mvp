# Railway Deploy MVP Report

## 本次完成内容

1. Flutter Web 已可构建。
2. Home + Store + Wallet + Inventory + Fishing mock 闭环已保留并可进入 Web 构建产物。
3. 修复了 Flutter 默认 web 平台缺失问题。
4. 修复了 `flutter analyze` 的默认测试模板错误。
5. 部署入口已切到 `office-fishing` 静态目录，支持 ` /office-fishing/ ` 和 ` /office-fishing.html `。

## 涉及文件

- `fishing_office_flutter/lib/main.dart`
- `fishing_office_flutter/test/widget_test.dart`
- `fishing_office_flutter/lib/core/engine/first_world_bridge.dart`
- `fishing_office_flutter/lib/core/engine/meaning_engine.dart`
- `fishing_office_flutter/lib/core/engine/ocean_ecology.dart`
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `server.js`
- `public/office-fishing/`
- `fishing_office_flutter/build/web/`

## 当前部署链路

Flutter 代码先构建为 Web 静态产物，然后由根目录 Node 静态服务提供访问。

访问路径：

- ` /office-fishing/ `
- ` /office-fishing.html `

这两个路径最终都映射到 Flutter Web 首页。

## Flutter Build

执行命令：

```bash
flutter build web --release --base-href /office-fishing/
```

结果：

- 构建成功
- 生成 `build/web`

## WalletProvider / InventoryProvider / DialogManager

本次没有改动业务逻辑，只保留已有 mock 闭环。

### WalletProvider

- 保持 `fish_coin` mock 余额
- 购买时由 Provider 扣减

### InventoryProvider

- 购买成功后增加本地库存

### DialogManager

- 商品详情
- 确认购买
- 购买成功
- 摸鱼币不足

均继续由 DialogManager 统一打开。

## 当前仍是 mock 的部分

1. 真实支付。
2. 真实数据库持久化。
3. 真实 API 接入。
4. 交易流水回写。
5. 远端钱包余额同步。
6. 远端库存同步。

## 仍需后续接入的位置

- Wallet API
- Inventory API
- Transaction API
- Database persistence
- Railway 自动部署触发链

## 静态检查

- `flutter analyze` 已通过

## 当前测试地址

部署运行时应访问：

- `https://<Railway域名>/office-fishing/`
- `https://<Railway域名>/office-fishing.html`

如果 Railway 已接好自动部署，这两个地址会指向同一份 Flutter Web 首页。
