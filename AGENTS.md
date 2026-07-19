//
//  AGENTS.md
//  图文APP
//
//  Created by chenanqi on 2026/7/19.
//
# AGENTS.md

## Product
这是一个 SwiftUI iOS 摄影/插画社区 App，名称为“花火记”。

## 设计稿
参考 OpenDesign 设计稿：
- OpenDesign/huahuoji-ios-home.html
- OpenDesign/index.html
- OpenDesign/detail.html
- OpenDesign/publish.html

## 技术约束
- 首页 TabView 使用系统默认方案
- 不主动引入第三方库；当前已由用户明确批准并接入 Nuke/NukeUI，后续图片和头像加载继续使用 NukeUI，不再额外引入其他图片库
- 如使用 ObservableObject，请 import Combine

## 当前实现约定
- 首页数据来自 Unsplash `GET /search/photos`，UI 保持中文，实际 API query 使用英文映射
- Unsplash Access Key 只能通过环境变量、Info.plist 注入或本地忽略文件 `Config/Unsplash.local.xcconfig` 提供，不要将完整 key 写入 git、源码常量或 logs
- 首页图片卡片必须保持同一外宽；图片宽度等于卡片外宽，图片高度只随真实图片比例变化
- 首页瀑布流左边距、中间列间距、右边距必须一致；修改布局时优先保留现有像素对齐的 `MasonryGrid` / `MasonryMetrics` 方案
- 首页卡片、详情页作者区和“我的”收藏卡片应显示 Unsplash 用户头像，头像来自 `user.profile_image`，使用 `AvatarView(url:size:)`
- “我的”页收藏为当前会话内状态：详情页或首页点亮爱心后进入收藏页，取消收藏后同步更新首页状态
- App 图标使用 `AppIcon.appiconset` 中的普通、深色、着色三套 1024x1024 PNG

## 交付要求
- 使用 SwiftUI 原生实现，不使用 WebView 承载 HTML
- 当前版本已接入 Unsplash 首页数据；新增功能仍优先保持 SwiftUI 原生实现和现有数据流
- 每次任务完成时，将本次改动以 markdown 格式写入到 logs 文件夹
- 确保在 iPhone 17 模拟器下可编译成功
- 运行过程中产生的临时文件请不要放入 git

