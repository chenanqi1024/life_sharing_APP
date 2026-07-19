//
//  HuahuojiModels.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import Foundation

struct Post: Identifiable, Hashable {
    let id: String
    var title: String
    let author: String
    let authorUsername: String?
    var likes: Int
    let style: PostStyle
    let size: PostSize
    let copy: String
    let thumbnailURL: URL?
    let detailImageURL: URL?
    let imageHeightRatio: Double?
    let sourceURL: URL?
    let authorProfileURL: URL?
    let authorAvatarURL: URL?
    let sourceLabel: String
    let timeText: String
    var liked: Bool = false

    init(
        id: String,
        title: String,
        author: String,
        authorUsername: String?,
        likes: Int,
        style: PostStyle,
        size: PostSize,
        copy: String,
        thumbnailURL: URL?,
        detailImageURL: URL?,
        imageHeightRatio: Double? = nil,
        sourceURL: URL?,
        authorProfileURL: URL?,
        authorAvatarURL: URL? = nil,
        sourceLabel: String,
        timeText: String,
        liked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.authorUsername = authorUsername
        self.likes = likes
        self.style = style
        self.size = size
        self.copy = copy
        self.thumbnailURL = thumbnailURL
        self.detailImageURL = detailImageURL
        self.imageHeightRatio = imageHeightRatio
        self.sourceURL = sourceURL
        self.authorProfileURL = authorProfileURL
        self.authorAvatarURL = authorAvatarURL
        self.sourceLabel = sourceLabel
        self.timeText = timeText
        self.liked = liked
    }

    var heightWeight: Double {
        thumbnailHeightRatio + Double((title.count + 9) / 10) * 0.16
    }

    var thumbnailHeightRatio: Double {
        imageHeightRatio ?? size.heightRatio
    }

    mutating func toggleFavorite() {
        liked.toggle()
        likes = liked ? likes + 1 : max(likes - 1, 0)
    }

    var tags: [String] {
        style.tags
    }

    var authorBio: String {
        if let authorUsername {
            "@\(authorUsername) · Unsplash 创作者"
        } else {
            "\(tags[0].dropFirst()) · 摄影 / 插画创作者"
        }
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
            id: "sample-0",
            title: "窗边一束蓝调光，适合画安静人物",
            author: "阿岚",
            authorUsername: nil,
            likes: 128,
            style: .window,
            size: .tall,
            copy: "把白纱窗和浅蓝阴影留出来，人物只用一点暖粉做脸颊，画面会有很轻的呼吸感。适合做头像、日记插画或摄影情绪板。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "1 小时前"
        ),
        Post(
            id: "sample-1",
            title: "奶油黄背景里的小花束拍法",
            author: "椿野",
            authorUsername: nil,
            likes: 96,
            style: .studio,
            size: .medium,
            copy: "用低饱和黄色垫纸做背景，花束不要摆正，留一角空白给手写字。成片更像随手记录，而不是商品图。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "2 小时前"
        ),
        Post(
            id: "sample-2",
            title: "胶片颗粒感：别把阴影提太亮",
            author: "Momo",
            authorUsername: nil,
            likes: 214,
            style: .film,
            size: .short,
            copy: "阴影保留一点密度，亮部用柔和奶白压住，颗粒才会像真实胶片。适合咖啡店、街角和傍晚窗口。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "3 小时前"
        ),
        Post(
            id: "sample-3",
            title: "薄荷绿 + 珊瑚粉，春天封面组合",
            author: "六月",
            authorUsername: nil,
            likes: 183,
            style: .garden,
            size: .tall,
            copy: "薄荷绿负责清爽，珊瑚粉只放在标题或小物件上。两种颜色都别铺满，画面会更像轻插画杂志页。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "4 小时前"
        ),
        Post(
            id: "sample-4",
            title: "桌面拼贴：相纸、便签和一枚夹子",
            author: "栗子",
            authorUsername: nil,
            likes: 77,
            style: .desk,
            size: .medium,
            copy: "先定一个主照片，再用便签和色块做边角。元素数量控制在三种以内，留白比贴满更有 Pinterest 感。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "5 小时前"
        ),
        Post(
            id: "sample-5",
            title: "雨后路灯可以这样画成淡紫色",
            author: "星回",
            authorUsername: nil,
            likes: 142,
            style: .night,
            size: .short,
            copy: "路灯不要用纯黄，混一点淡紫灰，雨后的空气会更柔。地面反光用长条形，不要画得太均匀。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "6 小时前"
        ),
        Post(
            id: "sample-6",
            title: "拍插画本时，让手指只出现一点点",
            author: "小满",
            authorUsername: nil,
            likes: 65,
            style: .studio,
            size: .short,
            copy: "手指只压住纸角，能给画面增加真实使用感。背景保持浅色，插画本的色彩自然成为主角。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "7 小时前"
        ),
        Post(
            id: "sample-7",
            title: "一张照片拆出三组头像配色",
            author: "南风",
            authorUsername: nil,
            likes: 201,
            style: .window,
            size: .tall,
            copy: "从照片里抽取背景、中间调和点缀色，再分别给头像的衣服、肤色和小饰品。这样配色会自然很多。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "8 小时前"
        ),
        Post(
            id: "sample-8",
            title: "用圆角色块画出可爱的旅行票根",
            author: "山茶",
            authorUsername: nil,
            likes: 118,
            style: .garden,
            size: .medium,
            copy: "票根边缘不用追求真实，圆角和浅色块更适合日常记录。加一行日期和地点，就能形成完整的小故事。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "9 小时前"
        ),
        Post(
            id: "sample-9",
            title: "夜晚橱窗：只保留两处高光",
            author: "苒苒",
            authorUsername: nil,
            likes: 156,
            style: .film,
            size: .tall,
            copy: "高光太多会散，保留橱窗灯和玻璃反射两处就够。其余部分用低对比粉紫过渡，画面更安静。",
            thumbnailURL: nil,
            detailImageURL: nil,
            sourceURL: nil,
            authorProfileURL: nil,
            sourceLabel: "花火记",
            timeText: "10 小时前"
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

    static func from(width: Int, height: Int) -> PostSize {
        guard width > 0, height > 0 else {
            return .medium
        }

        let ratio = Double(height) / Double(width)
        if ratio >= 1.18 {
            return .tall
        }
        if ratio <= 0.92 {
            return .short
        }
        return .medium
    }

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
