# 2026-07-20 上传页图片比例修复

## 改动
- 重构上传页图片缩略图 `PhotoTile`，使用明确的方形容器承载用户上传图片。
- 上传图片在容器内使用 `scaledToFill()`，并显式绑定容器宽高，保证按原图比例裁切，不再被 SwiftUI 网格拉伸变形。
- 新增通用 `SquarePhotoTile`，让上传图片格和“添加图片”格使用同一套方形尺寸约束。
- 清理旧的缩略图修饰顺序，避免 `frame(minHeight:)` 与 `aspectRatio` 组合造成比例提案混乱。

## 验证
- `git diff --check` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。
