# 2026-07-19 首页栅格像素对齐

## 改动
- 首页瀑布流改为固定三段间距：左边距、中间列间距、右边距均为 `18pt`。
- 使用 `displayScale` 将列宽对齐到真实像素，再反推 grid 宽度并居中，避免 Simulator 缩放后出现视觉偏差。
- 收敛首页卡片横向阴影，减少左右两列阴影在中缝叠加造成的“间距变窄”观感。

## 验证
- `git diff --check` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。
- 已安装到 iPhone 17 Pro 模拟器并截图验证：`/tmp/huahuoji-spacing-pixel-aligned.png`。
- 新截图宽度为 `1206px`，左边距、中缝、右边距均为 `54px`，对应 `18pt`。
