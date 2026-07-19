# 2026-07-19 首页两列间距修正

## 改动
- 将首页瀑布流外边距与列间距统一为 `12pt`。
- 移除列宽计算里的向下取整，避免奇数屏宽下产生 1pt 剩余导致视觉偏移。
- 为瀑布流外层容器指定屏幕宽度，让两列布局按同一基准对齐。
- 让首页卡片在列内明确撑满宽度，减少 SwiftUI 理想宽度计算带来的视觉不齐。

## 验证
- `git diff --check` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。
