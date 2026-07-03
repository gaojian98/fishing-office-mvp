# Demo Flow

## 目标

验证 FishingOffice 第一版最小可玩闭环在统一 Runtime 下可以连续运行，不报错。

## 流程

1. 首次进入首页。
2. 领取基础鱼饵。
3. 执行抛线。
4. 进入等待状态。
5. 生成等待事件。
6. 收线得到鱼获。
7. 打开结果处理。
8. 执行出售，Wallet 增加。
9. 再次抛线。
10. 使用鱼作为下一次鱼饵。
11. 进入更高一阶鱼链。
12. 结束当前演示链路。

## 验证点

- Home 只读 Runtime
- Debug Panel 正确显示状态
- Wallet / Inventory / Transaction 能同步变化
- Waiting / FishChain / Fishing 的 mock 逻辑不被破坏
- Web 构建正常

## 当前实现状态

此流程已通过现有 mock 逻辑接通，仍不接数据库和真实 API。
