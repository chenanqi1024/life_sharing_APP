//
//  UnsplashClient.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import Foundation

struct UnsplashSearchPage {
    let posts: [Post]
    let page: Int
    let totalPages: Int
}

enum UnsplashClientError: LocalizedError {
    case missingAccessKey
    case invalidURL
    case requestFailed(statusCode: Int)
    case emptyResults

    var errorDescription: String? {
        switch self {
        case .missingAccessKey:
            "请先配置 Unsplash Access Key。"
        case .invalidURL:
            "搜索链接生成失败。"
        case .requestFailed(let statusCode):
            "Unsplash 请求失败，状态码 \(statusCode)。"
        case .emptyResults:
            "没有找到相关灵感。"
        }
    }
}

enum UnsplashConfig {
    static var accessKey: String? {
        if let value = normalized(ProcessInfo.processInfo.environment["UNSPLASH_ACCESS_KEY"]) {
            return value
        }

        if let value = normalized(Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String) {
            return value
        }

        if let value = normalized(Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String) {
            return value
        }

        return bundledConfigAccessKey
    }

    private static var bundledConfigAccessKey: String? {
        guard let url = Bundle.main.url(forResource: "UnsplashConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dictionary = plist as? [String: Any] else {
            return nil
        }

        return normalized(dictionary["UnsplashAccessKey"] as? String)
    }

    private static func normalized(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("$(") else {
            return nil
        }
        return trimmed
    }
}

struct UnsplashClient {
    private let baseURL = URL(string: "https://api.unsplash.com/search/photos")

    func searchPhotos(query: String, page: Int, perPage: Int = 20) async throws -> UnsplashSearchPage {
        guard let accessKey = UnsplashConfig.accessKey else {
            throw UnsplashClientError.missingAccessKey
        }
        guard let baseURL else {
            throw UnsplashClientError.invalidURL
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "order_by", value: "relevant"),
            URLQueryItem(name: "content_filter", value: "high")
        ]

        guard let url = components?.url else {
            throw UnsplashClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashClientError.requestFailed(statusCode: -1)
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw UnsplashClientError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let payload = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
        let posts = payload.results.enumerated().map { index, photo in
            photo.post(displayIndex: index)
        }

        return UnsplashSearchPage(posts: posts, page: page, totalPages: max(payload.totalPages, 1))
    }
}

private struct UnsplashSearchResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

private struct UnsplashPhoto: Decodable {
    let id: String
    let width: Int
    let height: Int
    let description: String?
    let altDescription: String?
    let likes: Int
    let urls: UnsplashPhotoURLs
    let links: UnsplashPhotoLinks
    let user: UnsplashUser

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case altDescription = "alt_description"
        case likes
        case urls
        case links
        case user
    }

    func post(displayIndex: Int) -> Post {
        let style = PostStyle.allCases[displayIndex % PostStyle.allCases.count]
        let title = firstNonEmpty(description, altDescription, "Untitled inspiration")
        let copy = firstNonEmpty(
            altDescription,
            description,
            "来自 Unsplash 的摄影灵感，适合收藏为下一次创作的视觉参考。"
        )

        return Post(
            id: id,
            title: title.capitalizedSentence,
            author: user.name,
            authorUsername: user.username,
            likes: likes,
            style: style,
            size: PostSize.from(width: width, height: height),
            copy: copy.capitalizedSentence,
            thumbnailURL: urls.small,
            detailImageURL: urls.regular,
            imageHeightRatio: thumbnailHeightRatio,
            sourceURL: links.html,
            authorProfileURL: user.links.html,
            authorAvatarURL: user.profileImage?.preferredURL,
            sourceLabel: "Unsplash",
            timeText: "来自 Unsplash"
        )
    }

    private func firstNonEmpty(_ values: String?...) -> String {
        for value in values {
            if let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
                return trimmed
            }
        }
        return "Untitled inspiration"
    }

    private var thumbnailHeightRatio: Double {
        guard width > 0, height > 0 else {
            return PostSize.medium.heightRatio
        }

        return min(max(Double(height) / Double(width), 0.72), 1.58)
    }
}

private struct UnsplashPhotoURLs: Decodable {
    let raw: URL?
    let regular: URL?
    let small: URL?
    let thumb: URL?
}

private struct UnsplashPhotoLinks: Decodable {
    let html: URL?
}

private struct UnsplashUser: Decodable {
    let username: String
    let name: String
    let profileImage: UnsplashProfileImage?
    let links: UnsplashUserLinks

    enum CodingKeys: String, CodingKey {
        case username
        case name
        case profileImage = "profile_image"
        case links
    }
}

private struct UnsplashUserLinks: Decodable {
    let html: URL?
}

private struct UnsplashProfileImage: Decodable {
    let small: URL?
    let medium: URL?
    let large: URL?

    var preferredURL: URL? {
        medium ?? small ?? large
    }
}

private extension String {
    var capitalizedSentence: String {
        guard let first else {
            return self
        }
        return first.uppercased() + String(dropFirst())
    }
}
