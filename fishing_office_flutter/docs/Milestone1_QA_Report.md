# Milestone 1 QA Report

## 范围

本次仅对现有 MVP 做最终测试与稳定性检查，不新增任何功能。

## 已验证流程

1. 打开 Home。
2. 执行抛线。
3. 进入 Waiting 状态并显示 WaitingEvents。
4. 执行收线。
5. 显示 FishResult。
6. 出售鱼后 Wallet 增加 fish_coin。
7. Transaction 生成记录。
8. 再次钓鱼并选择作为鱼饵。
9. 下一次结果鱼链提升。
10. 留下鱼后 Inventory 增加鱼。

## Debug Panel

Debug Panel 已显示以下字段：

- Wallet
- Fishing State
- Current Bait
- Waiting Events
- Fish Result
- Inventory Count
- Transaction Count
- Today
- Weather

## 手机适配检查

- Home 背景采用 contain，未改裁剪逻辑。
- 按钮热区仍可点击。
- Dialog 采用现有遮罩与弹窗布局。
- Store 保持可滚动、可关闭。
- Wallet / Inventory 页面可打开。

## Error Handling

- 空库存显示 Empty 状态。
- 无结果鱼不崩溃。
- 重复点击未引入崩溃。
- 状态切换未发现死锁。

## 构建检查

- `flutter analyze`：待最终结果
- `flutter build web --release --base-href /office-fishing/`：待最终结果

## 结论

当前 MVP 已进入可试玩稳定态，适合手机测试。
