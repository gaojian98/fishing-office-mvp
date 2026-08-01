# 《上班摸鱼》开发原则（Development Principles V1.0）

第一原则：程序越来越稳定，内容越来越丰富。

第二原则：所有游戏内容必须数据驱动（Data Driven）。

包括但不限于：

- 居民（Residents）
- 鱼（Fish）
- 对白（Dialogue）
- 故事（Story）
- 随机事件（Events）
- 节日（Festival）
- 世界成长（World Timeline）
- 图鉴（Collection）
- 商店商品（Shop Items）

全部使用 JSON 配置。

第三原则：新增内容尽量不修改 Flutter 代码。

目标：

- 新增一个居民，不修改 Flutter。
- 新增一种鱼，不修改 Flutter。
- 新增一段对白，不修改 Flutter。
- 新增一个故事，不修改 Flutter。
- 新增一个节日，不修改 Flutter。
- 新增一个商店商品，不修改 Flutter。

Flutter 负责：
- 渲染
- 动画
- 交互
- 状态管理

JSON 负责：
- 内容
- 数值
- 配置
- 剧情
- 世界

第四原则：产品描述能力，工程决定实现。

产品文档只定义：
- 玩家体验
- 世界规则
- 数据结构
- 验收标准

工程可以自由决定：
- Manager
- Module
- Repository
- Service
- Provider
- Cache

第五原则：保持向后兼容。

新增内容不能破坏已有玩法。

第六原则：所有提交必须通过：

flutter analyze
flutter test
flutter build

全部通过后才能进入下一 Sprint。
