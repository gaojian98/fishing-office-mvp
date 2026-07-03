# Runtime Integration Report

## 本次目标

把 FishingOffice 第一版可玩的 Home / Store / Wallet / Inventory / Fishing mock 闭环统一到一个 Runtime 入口，不再让 Home 页面分别读取多个 Provider。

## 已完成内容

1. 建立统一 `AppRuntime`。
2. Home 页面改为只读取 `AppRuntime`。
3. 建立仅 Debug 模式可见的 Debug Panel。
4. 增加 Demo Flow 的运行基础。
5. 建立统一日志输出入口。
6. 保持现有 mock 经济与钓鱼闭环不变。
7. 完成 `flutter analyze`。
8. 完成 `flutter build web`。

## Runtime 结构

`AppRuntime` 聚合以下运行时数据：

- Wallet
- Fishing
- FishChain
- Inventory
- Transaction
- Waiting
- Today
- Weather

## Home 数据来源

Home 页面不再直接读取多个 Provider。

它只读取：

- `appRuntimeProvider`

然后从 Runtime snapshot 中获取：

- 当前鱼饵
- 当前鱼获
- 钓鱼状态
- 当前会话
- 等待事件
- 库存数量
- 交易数量
- 当前天气
- 当前 Today

## Debug Panel

仅在 `kDebugMode` 下显示。

显示字段：

- Wallet
- Current Bait
- Current Fish
- Fishing State
- Current Session
- Waiting Events
- Inventory Count
- Transaction Count
- Current Weather
- Current Today

## Demo Flow

当前闭环仍沿用已有 mock 逻辑：

1. 领取基础鱼饵
2. 抛线
3. 等待
4. 钓鱼
5. 结果
6. 出售
7. Wallet 增加
8. 再次抛线
9. 使用鱼饵
10. 升级鱼链

## 统一日志

Debug 模式下新增日志输出：

- Fishing Log
- Wallet Log
- Inventory Log
- Waiting Log
- FishChain Log
- Transaction Log
- Runtime Log

## 统一错误处理

本次只完成运行时聚合层的统一出口。

后续如果再接新的异步数据源，需要继续把该数据源包装成统一的 loading / success / empty / error 状态，再接入 Runtime。

## 构建与校验

- `flutter analyze`：通过
- `flutter build web --release --base-href /office-fishing/`：通过

## 当前状态

当前已进入可玩的整合态，适合继续做手机端验证。

## 当前未完成项

1. 还没有把所有页面完全改成只读 Runtime。
2. 还没有把所有异步数据源统一包装成完整的 loading / success / empty / error 体系。
3. 还没有补更详细的 Demo 自动化测试。
4. 还没有做真实 API / 数据库接入。
