//
//  HuahuojiModels.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import Foundation

struct Post: Identifiable, Hashable {
    let id: Int
    var title: String
    let author: String
    var likes: Int
    let style: PostStyle
    let size: PostSize
    let copy: String
    var liked: Bool = false

    var heightWeight: Double {
        size.heightRatio + Double((title.count + 9) / 10) * 0.16
    }

    var tags: [String] {
        style.tags
    }

    var authorBio: String {
        "\(tags[0].dropFirst()) · 摄影 / 插画创作者"
    }

    var comments: [Comment] {
        let paletteWord = String(tags[0].dropFirst())
        return [
            Comment(id: 0, name: "南枝", text: "这个\(paletteWord)好温柔，想拿来做下一组手账封面。", time: "刚刚"),
            Comment(id: 1, name: "小盐", text: "留白比例很舒服，收藏了，周末照着试一组。", time: "12 分钟前")
        ]
    }

    static let samplePosts: [Post] = [
        Post(
            id: 0,
            title: "窗边一束蓝调光，适合画安静人物",
            author: "阿岚",
            likes: 128,
            style: .window,
            size: .tall,
            copy: "把白纱窗和浅蓝阴影留出来，人物只用一点暖粉做脸颊，画面会有很轻的呼吸感。适合做头像、日记插画或摄影情绪板。"
        ),
        Post(
            id: 1,
            title: "奶油黄背景里的小花束拍法",
            author: "椿野",
            likes: 96,
            style: .studio,
            size: .medium,
            copy: "用低饱和黄色垫纸做背景，花束不要摆正，留一角空白给手写字。成片更像随手记录，而不是商品图。"
        ),
        Post(
            id: 2,
            title: "胶片颗粒感：别把阴影提太亮",
            author: "Momo",
            likes: 214,
            style: .film,
            size: .short,
            copy: "阴影保留一点密度，亮部用柔和奶白压住，颗粒才会像真实胶片。适合咖啡店、街角和傍晚窗口。"
        ),
        Post(
            id: 3,
            title: "薄荷绿 + 珊瑚粉，春天封面组合",
            author: "六月",
            likes: 183,
            style: .garden,
            size: .tall,
            copy: "薄荷绿负责清爽，珊瑚粉只放在标题或小物件上。两种颜色都别铺满，画面会更像轻插画杂志页。"
        ),
        Post(
            id: 4,
            title: "桌面拼贴：相纸、便签和一枚夹子",
            author: "栗子",
            likes: 77,
            style: .desk,
            size: .medium,
            copy: "先定一个主照片，再用便签和色块做边角。元素数量控制在三种以内，留白比贴满更有 Pinterest 感。"
        ),
        Post(
            id: 5,
            title: "雨后路灯可以这样画成淡紫色",
            author: "星回",
            likes: 142,
            style: .night,
            size: .short,
            copy: "路灯不要用纯黄，混一点淡紫灰，雨后的空气会更柔。地面反光用长条形，不要画得太均匀。"
        ),
        Post(
            id: 6,
            title: "拍插画本时，让手指只出现一点点",
            author: "小满",
            likes: 65,
            style: .studio,
            size: .short,
            copy: "手指只压住纸角，能给画面增加真实使用感。背景保持浅色，插画本的色彩自然成为主角。"
        ),
        Post(
            id: 7,
            title: "一张照片拆出三组头像配色",
            author: "南风",
            likes: 201,
            style: .window,
            size: .tall,
            copy: "从照片里抽取背景、中间调和点缀色，再分别给头像的衣服、肤色和小饰品。这样配色会自然很多。"
        ),
        Post(
            id: 8,
            title: "用圆角色块画出可爱的旅行票根",
            author: "山茶",
            likes: 118,
            style: .garden,
            size: .medium,
            copy: "票根边缘不用追求真实，圆角和浅色块更适合日常记录。加一行日期和地点，就能形成完整的小故事。"
        ),
        Post(
            id: 9,
            title: "夜晚橱窗：只保留两处高光",
            author: "苒苒",
            likes: 156,
            style: .film,
            size: .tall,
            copy: "高光太多会散，保留橱窗灯和玻璃反射两处就够。其余部分用低对比粉紫过渡，画面更安静。"
        )
    ]
}

enum PostStyle: String, Hashable, CaseIterable {
    case studio
    case window
    case film
    case garden
    case desk
    case night

    var tags: [String] {
        switch self {
        case .window:
            ["#窗边光影", "#蓝调摄影", "#安静插画"]
        case .studio:
            ["#奶油色系", "#花束拍摄", "#日常布景"]
        case .film:
            ["#胶片感", "#低饱和调色", "#街角灵感"]
        case .garden:
            ["#薄荷绿", "#春日配色", "#封面灵感"]
        case .desk:
            ["#桌面拼贴", "#相纸便签", "#创作日常"]
        case .night:
            ["#雨夜光影", "#淡紫色", "#氛围记录"]
        }
    }
}

enum PostSize: String, Hashable {
    case tall
    case medium
    case short

    var heightRatio: Double {
        switch self {
        case .tall:
            1.34
        case .medium:
            1.08
        case .short:
            0.86
        }
    }
}

struct Comment: Identifiable, Hashable {
    let id: Int
    let name: String
    let text: String
    let time: String
}
