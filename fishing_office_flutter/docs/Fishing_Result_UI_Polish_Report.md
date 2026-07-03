# Fishing Result UI Polish MVP Report

## 1. 本次实现了哪些功能
- Home 状态展示更清楚：
  - 当前钓鱼状态
  - 当前鱼饵
  - 等待事件列表
  - 当前结果鱼
  - 可执行动作
- FishResultDialog 文案更清晰：
  - 鱼名
  - 等级
  - 可出售摸鱼币
  - 可获得积分
  - 三个选择按钮
- 执行结果后增加轻提示：
  - 出售成功
  - 已放入背包
  - 已作为下一次鱼饵

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/pages/home/home_page.dart`
- `fishing_office_flutter/docs/Fishing_Result_UI_Polish_Report.md`
- `fishing_office_flutter/docs/Fishing_Result_UI_Polish_Todo.md`

## 3. Home 当前展示内容
- 当前钓鱼状态
- 当前鱼饵
- 等待事件列表
- 当前结果鱼
- 当前可执行动作

## 4. FishResultDialog 当前文案
- 鱼名
- 等级
- 可出售摸鱼币
- 可获得积分
- 按钮：
  - 出售
  - 留下
  - 作为鱼饵

## 5. 操作反馈
- 出售后提示：出售成功
- 留下后提示：已放入背包
- 作为鱼饵后提示：已作为下一次鱼饵

## 6. 当前仍是 mock 的部分
- 所有结果仍然走 mock Provider。
- 不接数据库。
- 不接真实 API。
- 不改经济规则。
- 不做真实概率。

## 7. 后续需要接 API / Database 的位置
- 提示弹窗后续可替换为统一 Toast / Dialog 体系。
- 结果文案后续可继续读配置源。
- Home 文案后续可继续保持只读 Provider。

