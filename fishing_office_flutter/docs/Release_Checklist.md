# Release Checklist

## Build

- [x] `flutter analyze`
- [x] `flutter build web --release --base-href /office-fishing/`

## Git

- [ ] 变更已整理
- [ ] `git add`
- [ ] `git commit`
- [ ] `git push`

## Railway

- [x] Node 静态服务可提供页面
- [ ] Railway 自动部署完成
- [ ] Railway Build Command 确认
- [ ] Railway Start Command 确认

## Domain

- [x] 已确认测试域名 `p3.up.railway.app`
- [ ] 如需自定义域名，完成绑定

## HTTPS

- [x] Railway 域名为 HTTPS 访问
- [ ] 自定义域名证书如有需要再确认

## Browser

- [x] 首次打开可进入 Home
- [x] 刷新不应依赖根路径
- [x] 浏览器返回不应产生路由错误

## Mobile

- [x] iPhone 端可打开
- [x] `/office-fishing/` 可访问
- [x] `/office-fishing.html` 可访问
- [ ] 进一步手机真机验收
