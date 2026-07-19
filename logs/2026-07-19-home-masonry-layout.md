# 2026-07-19 首页瀑布流布局适配

## 本次改动

- 修正首页瀑布流列宽：根据屏幕可用宽度计算固定两列，每列宽度完全一致。
- 统一图片卡片之间的水平和垂直间距为 `12pt`。
- 缩略图高度改为优先使用 Unsplash 返回的真实宽高比，宽度固定、高度自然变化。
- 增加首页底部滚动留白，避免最后一行内容被系统 tab bar 遮挡。

## 验证

- 已运行并通过：

```bash
xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet
```

- 已安装并启动到 iPhone 17 模拟器，截图确认首页两列卡片宽度一致、图片间距一致。
