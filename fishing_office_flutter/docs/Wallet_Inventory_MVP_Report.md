# Wallet + Inventory MVP Report

## 1. 本次实现了哪些功能
- Wallet 最小可运行页面。
- Inventory 最小可运行页面。
- 本地 Transaction 占位记录。
- `/wallet` 页面路由可打开。
- `/inventory` 页面路由可打开。
- Store 购买后会同步扣减余额、增加库存、生成交易记录。

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/core/navigation/navigation_manager.dart`
- `fishing_office_flutter/lib/main.dart`
- `fishing_office_flutter/lib/pages/wallet/wallet_page.dart`
- `fishing_office_flutter/lib/pages/inventory/inventory_page.dart`
- `fishing_office_flutter/lib/pages/store/store_dialog_page.dart`
- `fishing_office_flutter/docs/Wallet_Inventory_MVP_Report.md`
- `fishing_office_flutter/docs/Wallet_Inventory_MVP_Todo.md`

## 3. Wallet / Inventory / Transaction 当前链路
1. Store 页面读取 `StoreConfigBundle`。
2. 用户购买商品后调用 `WalletManagerView.spend()`。
3. 余额足够时，调用 `InventoryManagerView.addItem()`。
4. 同时写入 `TransactionManagerView.addRecord()`。
5. Wallet 页面只读 `walletManagerProvider`。
6. Inventory 页面只读 `inventoryManagerProvider` 和 `transactionManagerProvider`。
7. `StoreDialogPage` 入口支持跳转 `/wallet` 和 `/inventory`。

## 4. WalletProvider 如何扣除 fish_coin
- `WalletManagerView` 维护 mock `fishCoin`。
- 初始值为 `1000`。
- `spend(amount)` 只在余额足够时扣减。
- 页面不直接修改余额。

## 5. InventoryProvider 如何增加商品
- `InventoryManagerView` 维护内存中的 `InventoryEntry`。
- `addItem(...)` 接收商品完整信息并累加数量。
- Inventory 页面通过 `entriesByCategory()` 分类展示。

## 6. Transaction 如何生成
- Store 购买成功后创建 `TransactionRecord`。
- 字段包含：
  - `id`
  - `type`
  - `currency`
  - `amount`
  - `itemId`
  - `itemName`
  - `createdAt`
- 当前仅保存在本地内存，不接数据库。

## 7. 当前仍是 mock 数据的部分
- Wallet 余额仍是 mock。
- Inventory 仍是内存数据。
- Transaction 仍是内存数据。
- 不接真实支付。
- 不接真实 API。
- 不接真实数据库。

## 8. 后续需要接 API / Database 的位置
- Wallet 真实资产：替换 `WalletManagerView` 的 mock 状态。
- Inventory 持久化：替换 `InventoryManagerView` 的内存存储。
- Transaction 持久化：接入数据库和 API。
- 页面层继续只读 Provider，不直接写业务状态。
