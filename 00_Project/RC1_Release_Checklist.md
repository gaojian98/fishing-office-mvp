# RC1 Release Checklist

Version: v1.0.0-rc.1
Updated By: Phase 5 Pack 29 Final Bug Fix Sprint

- [x] analyze PASS
- [x] test PASS
- [x] release build PASS
- [x] P0 = 0
- [x] P1 = 0
- [x] P2 open = 0
- [x] 存档兼容 PASS
- [x] 核心闭环 PASS
- [x] 20 轮核心流程回归 PASS
- [x] 30 天模拟 PASS
- [x] 90 天模拟 PASS
- [x] 世界模拟 PASS
- [x] JSON 校验 PASS
- [x] 资源校验 PASS
- [x] 鱼饵链无断链/循环 PASS
- [x] 奖励一致性 PASS
- [x] UI 无回退
- [x] 无本地绝对路径依赖
- [x] 无 release 调试入口
- [x] 未 Push Git

## Notes

- Debug hotspot and debug panel query flags are guarded by `kDebugMode`; they are not active in release builds.
- Current local validation URL remains `http://127.0.0.1:3101`.
- Remaining P3 items are documented in `106_Releases/v1.0.0-rc.1/Known_Issues.md` and do not block Gold Master review.
