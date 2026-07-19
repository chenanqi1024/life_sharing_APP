# 2026-07-19 首页接入 Unsplash + NukeUI

## 本次改动

- 将首页数据源从本地样例切换为 Unsplash `GET /search/photos` 实时搜索结果。
- 新增 `UnsplashClient`，负责公共 `Client-ID` 认证、`Accept-Version: v1`、搜索参数组装、响应解码和 `Post` 映射。
- 为 `Post` 模型补充 Unsplash 图片 URL、作者账号、来源链接、来源名称和时间文案等展示字段。
- 使用 Swift Package Manager 引入 Nuke，并链接 `NukeUI` 产品；首页卡片和详情页主图改用 `LazyImage` 加载。
- 首页保留双列瀑布流和频道 UI，新增加载、空结果、缺少 key、错误重试和分页加载状态。
- 中文频道继续面向用户展示，实际请求使用英文 query 映射，减少中文搜索 beta 能力带来的不稳定。
- 新增 `Config/Unsplash.xcconfig` 作为构建配置入口，并通过被 git 忽略的 `Config/Unsplash.local.xcconfig` 注入本地 Access Key。
- 新增构建阶段生成 app bundle 内的 `UnsplashConfig.plist`，运行时从该文件读取 Access Key。

## 验证

- 已运行并通过依赖解析：

```bash
xcodebuild -resolvePackageDependencies -project '图文APP.xcodeproj' -scheme '图文APP'
```

- 已运行并通过 iPhone 17 模拟器构建：

```bash
xcodebuild -project '图文APP.xcodeproj' -scheme '图文APP' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/huahuoji-derived build
```

- 验证结果：`BUILD SUCCEEDED`，Nuke 解析版本为 `13.0.6`。
- 已安装并启动到 iPhone 17 模拟器，首页截图确认进入真实 Unsplash 图片流。

## 注意

- 未接入 Unsplash OAuth、Secret Key、下载跟踪或服务端代理。
- 完整 Access Key 未写入源码或工程文件；本地配置文件已加入 `.gitignore`，构建脚本已关闭环境变量日志输出。
