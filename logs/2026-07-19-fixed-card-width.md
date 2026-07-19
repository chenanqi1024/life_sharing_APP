# 2026-07-19 首页卡片固定宽度

## 改动
- `PostCard` 新增显式 `cardWidth`，卡片外宽不再由内容、文字或图片加载状态决定。
- 首页图片区域固定为 `cardWidth`，高度按 `cardWidth * thumbnailHeightRatio` 计算。
- 底部文字区宽度固定为 `cardWidth - 20pt`，再加左右 `10pt` 内边距，保证整体卡片仍为同一宽度。
- `MasonryMetrics` 同时输出 grid 宽度和列宽，首页瀑布流中每张卡片都使用同一个列宽。

## 验证
- `git diff --check` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。
- 已安装到 iPhone 17 Pro 模拟器并截图验证：`/tmp/huahuoji-fixed-card-width.png`。
- 新截图宽度为 `1206px`，每张卡片宽度为 `522px`（`174pt`），左边距、中缝、右边距均为 `54px`（`18pt`）。
