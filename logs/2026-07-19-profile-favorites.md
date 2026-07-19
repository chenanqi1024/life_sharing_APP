# 2026-07-19 我的收藏功能

## 改动
- 在 `ContentView` 增加当前会话收藏池，首页结果和“我的”收藏页共享同一套收藏状态。
- 详情页爱心点击后调用统一的 `Post.toggleFavorite()`，并同步写入收藏池。
- 首页卡片爱心也接入同一条收藏回调；Unsplash 重新加载结果时会合并已有收藏状态。
- “我的”页从占位页改为收藏列表，包含收藏计数、空状态、收藏卡片、取消收藏和进入详情。
- 收藏卡片拆开行点击区域和右侧爱心按钮，避免嵌套按钮导致交互冲突。

## 验证
- `git diff --check` 通过。
- `plutil -lint 图文APP.xcodeproj/project.pbxproj` 通过。
- `xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build -quiet` 通过。

## 备注
- 收藏为当前会话内状态，尚未接入本地持久化或用户账号同步。
