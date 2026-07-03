# 上班摸鱼手机首页

React Native / Expo 原型，按上传 UI 图实现透明热区、二级弹窗和基础钓鱼状态。

## 运行

```bash
cd mobile-moyu-home
npm install
npm run web
```

iPhone 13 预览尺寸建议使用 `390 x 844`。真机预览可运行：

```bash
npm start
```

然后使用 Expo Go 扫码。

## 替换高清 UI 图

替换 `assets/ui/home.png` 即可。当前设计稿尺寸是 `1024 x 1536`，热区坐标在 `src/data/hotspots.js` 中集中维护。

如果后续 UI 图改成标准 iPhone 13 比例 `390 x 844`，保持 `BACKGROUND_FIT = "stretch"` 即可让热区一一对应。
