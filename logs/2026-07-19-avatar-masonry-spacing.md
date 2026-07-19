# 2026-07-19 头像与首页间距修复

## 改动
- 从 Unsplash `search/photos` 响应的 `user.profile_image` 中解码作者头像 URL。
- `Post` 增加 `authorAvatarURL` 字段，首页、详情页和“我的”收藏卡片传入作者头像。
- `AvatarView` 改为支持 NukeUI `LazyImage` 远程加载头像，并保留渐变占位兜底。
- 首页瀑布流从手动两列 `HStack` 改为自定义 `MasonryGrid`，按实际卡片高度测量后放入较短列。
- 首页左边距、中间列间距、右边距统一使用 `12pt`，避免列宽估算导致视觉不齐。

## 验证
- `git diff --check` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。
- 已在 iPhone 17 Pro 模拟器安装启动并截图验证首屏头像加载与两列间距；截图路径：`/tmp/huahuoji-avatar-spacing.png`。

## 备注
- 标准 iPhone 17 模拟器启动时卡在 System App 阶段，因此视觉截图使用已启动的 iPhone 17 Pro；编译验证仍使用 iPhone 17 destination。
