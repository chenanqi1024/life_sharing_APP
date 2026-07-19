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
- 不主动引入第三方库
- 如使用 ObservableObject，请 import Combine

## 交付要求
- 使用 SwiftUI 原生实现，不使用 WebView 承载 HTML
- 第一版只做页面，无需接入数据
- 每次任务完成时，将本次改动以 markdown 格式写入到 logs 文件夹
- 确保在 iPhone 17 模拟器下可编译成功
- 运行过程中产生的临时文件请不要放入 git


