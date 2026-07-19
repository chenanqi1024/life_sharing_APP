# 2026-07-19 花火记 SwiftUI 原生实现

## 本次改动

- 将 Hello World 入口替换为系统 `TabView`，包含“首页 / 发布 / 我的”三个 tab。
- 新增本地帖子模型、评论模型、样式枚举和设计 token，静态承载 OpenDesign 中的 10 条灵感内容。
- 使用 SwiftUI 原生实现首页搜索、频道筛选、两列瀑布流、喜欢状态和详情页跳转。
- 使用 SwiftUI 原生实现详情页，包含作者、关注、主视觉、正文、标签、评论和底部互动栏，并在详情页隐藏系统 tab bar。
- 使用 `PhotosPicker` 实现发布页本地选图、缩略图删除、标题 40B 限制、详情计数、草稿状态和发布成功回首页。
- 实现“我的花火”占位页。
- 修复 Xcode 工程误把 `AGENTS.md` 加入 Sources 的构建问题，并将 App 显示名改为“花火记”。

## 验证

- 已运行并通过：

```bash
xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build
```

- 沙盒内首次构建无法访问可用 Simulator 设备列表；随后用非沙盒权限重跑同一命令，构建成功。

## 后续修复

- 用户在 Xcode 中仍看到 `Unexpected input file: .../AGENTS` 后，进一步将 `AGENTS.md` 从 `.xcodeproj` 的工程导航引用中完全移除；文件仍保留在磁盘根目录，仅供 Codex/任务说明读取。
- 已使用 Xcode 默认 DerivedData 路径重新验证：

```bash
xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' build
```

- 验证结果：`BUILD SUCCEEDED`。
