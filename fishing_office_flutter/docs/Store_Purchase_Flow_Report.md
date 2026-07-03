# Store Purchase Flow Report

## Sprint
Sprint 004 - Store Purchase Flow MVP

## 1. 本次实现了哪些功能
- Store 商品列表展示。
- 商品详情弹窗。
- 确认购买弹窗。
- 购买成功弹窗。
- 摸鱼币不足弹窗。
- Mock WalletProvider 扣减逻辑。
- Mock InventoryProvider 增加商品逻辑。

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/pages/store/store_dialog_page.dart`
- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/docs/Store_Purchase_Flow_Report.md`
- `fishing_office_flutter/docs/Store_Purchase_Flow_Todo.md`

## 3. Store 购买流程现在的链路
1. `StoreDialogPage` 通过 `StoreConfigBundle` 读取 `Store/Data.json`。
2. 页面点击商品后，调用 `DialogManager.openStoreItemDetailDialog()` 打开商品详情。
3. 商品详情弹窗点击购买，调用 `DialogManager.openStoreConfirmDialog()` 打开确认购买。
4. 确认购买后，页面调用 `WalletManagerView.spend()` 执行余额扣减。
5. 若余额足够，再调用 `InventoryManagerView.addItem()` 增加库存。
6. 成功后由 `DialogManager.showPurchaseSuccessDialog()` 打开购买成功弹窗。
7. 若余额不足，由 `DialogManager.showInsufficientCoinDialog()` 打开不足弹窗。

## 4. WalletProvider 如何扣除 fish_coin
- `WalletManagerView` 初始余额为 `1000`。
- `spend(amount)` 先执行余额校验。
- 余额充足时扣减 `_fishCoin`，并触发 `notifyListeners()`。
- 余额不足时直接返回 `false`，不修改余额。

## 5. InventoryProvider 如何增加商品
- `InventoryManagerView` 使用内部 `Map<String, int>` 保存商品拥有数量。
- `addItem(itemId, quantity: 1)` 会把对应商品数量累加。
- 页面展示时通过 `ownedOf(item.id, fallback: item.owned)` 读取当前数量。

## 6. DialogManager 如何打开各类弹窗
- 商品详情：`openStoreItemDetailDialog()`
- 确认购买：`openStoreConfirmDialog()`
- 购买成功：`showPurchaseSuccessDialog()`
- 余额不足：`showInsufficientCoinDialog()`
- 所有弹窗仍然通过 `DialogManager` 统一打开，不在页面内直接创建临时业务弹窗。

## 7. 当前仍是 mock 数据的部分
- Wallet 余额仍是 mock 初始值 `fish_coin = 1000`。
- Inventory 仍是本地内存状态。
- 购买成功不写数据库。
- 购买成功不请求 API。

## 8. 后续需要接 API / Database 的位置
- Wallet 真实余额来源：替换 `WalletManagerView` 的 mock 存储。
- Inventory 持久化：替换 `InventoryManagerView` 的内存 Map。
- 交易记录：后续接入 `Transaction` / Economy / API。
- 商品拥有数量同步：后续通过数据库和 API 回写。

