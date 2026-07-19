//
//  HomeView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var posts: [Post]
    let favoritePosts: [Post]
    let onFavoriteChanged: (Post) -> Void
    @State private var path: [Post.ID] = []
    @State private var navigationPosts: [Post.ID: Post] = [:]

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                posts: $posts,
                favoritePosts: favoritePosts,
                onFavoriteChanged: onFavoriteChanged
            ) { postID in
                if let post = posts.first(where: { $0.id == postID }) {
                    navigationPosts[postID] = post
                }
                path.append(postID)
            }
            .navigationDestination(for: Post.ID.self) { postID in
                if let post = binding(for: postID) {
                    DetailView(post: post, onFavoriteChanged: onFavoriteChanged)
                } else {
                    MissingPostView()
                }
            }
        }
    }

    private func binding(for postID: Post.ID) -> Binding<Post>? {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            return $posts[index]
        }

        guard navigationPosts[postID] != nil else {
            return nil
        }

        return Binding(get: {
            navigationPosts[postID]!
        }, set: { post in
            navigationPosts[postID] = post
            onFavoriteChanged(post)
        })
    }
}

struct HomeView: View {
    @Binding var posts: [Post]
    let favoritePosts: [Post]
    let onFavoriteChanged: (Post) -> Void
    let openPost: (Post.ID) -> Void

    @Environment(\.displayScale) private var displayScale
    @State private var searchText = ""
    @State private var activeChannel = "今日灵感"
    @State private var loadState: HomeLoadState = .idle
    @State private var reloadToken = 0
    @State private var currentQuery = ""
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var isLoadingMore = false

    private let client = UnsplashClient()
    private let gridSpacing: CGFloat = 12
    private let gridBottomPadding: CGFloat = 110
    private let channels = ["今日灵感", "摄影", "插画", "胶片感", "配色"]
    private let channelQueries = [
        "今日灵感": "creative photography illustration",
        "摄影": "photography inspiration",
        "插画": "illustration art inspiration",
        "胶片感": "film photography",
        "配色": "color palette photography"
    ]
    private let keywordQueries = [
        "胶片": "film photography",
        "胶片感": "film photography",
        "窗边光": "window light portrait",
        "拼贴": "collage art photography",
        "配色": "color palette photography",
        "插画": "illustration art inspiration",
        "摄影": "photography inspiration"
    ]

    var body: some View {
        ZStack {
            HuahuojiBackground()

            VStack(spacing: 0) {
                HomeHeader(
                    searchText: $searchText,
                    activeChannel: $activeChannel,
                    channels: channels,
                    onChannelSelected: selectChannel,
                    onSearchSubmitted: submitSearch
                )
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 10)

                content
            }
        }
        .task(id: reloadToken) {
            await reload()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch loadState {
        case .idle, .loading:
            LoadingSearchView()
                .padding(.horizontal, 18)
                .padding(.top, 6)
        case .missingKey:
            HomeStatusView(
                systemName: "key",
                title: "需要配置 Unsplash",
                message: "请通过 UNSPLASH_ACCESS_KEY 注入 Access Key 后再加载首页。"
            )
            .padding(.horizontal, 18)
            .padding(.top, 6)
        case .empty:
            EmptySearchView()
                .padding(.horizontal, 18)
                .padding(.top, 6)
        case .failed(let message):
            HomeStatusView(
                systemName: "wifi.exclamationmark",
                title: "加载失败",
                message: message,
                buttonTitle: "重试",
                action: retry
            )
            .padding(.horizontal, 18)
            .padding(.top, 6)
        case .loaded:
            resultsGrid
        }
    }

    private var resultsGrid: some View {
        GeometryReader { proxy in
            let metrics = masonryMetrics(in: proxy.size.width)

            ScrollView {
                MasonryGrid(columns: 2, spacing: gridSpacing) {
                    ForEach(posts.indices, id: \.self) { index in
                        if let post = binding(for: posts[index].id) {
                            PostCard(
                                post: post,
                                cardWidth: metrics.columnWidth,
                                tiltDegrees: index.isMultiple(of: 2) ? -5 : 5
                            ) {
                                openPost(posts[index].id)
                            } onFavoriteChanged: { post in
                                onFavoriteChanged(post)
                            }
                        }
                    }
                }
                .frame(width: metrics.width)
                .frame(maxWidth: .infinity, alignment: .center)

                if canLoadMore {
                    LoadMoreView()
                        .padding(.vertical, 18)
                        .task {
                            await loadNextPage()
                        }
                }

                Spacer()
                    .frame(height: gridBottomPadding)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var canLoadMore: Bool {
        !posts.isEmpty && currentPage < totalPages && !isLoadingMore
    }

    private func binding(for postID: Post.ID) -> Binding<Post>? {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else {
            return nil
        }
        return $posts[index]
    }

    private func masonryMetrics(in availableWidth: CGFloat) -> MasonryMetrics {
        let rawColumnWidth = max(0, (availableWidth - gridSpacing * 3) / 2)
        let pixelAlignedColumnWidth = floor(rawColumnWidth * displayScale) / displayScale
        let gridWidth = pixelAlignedColumnWidth * 2 + gridSpacing

        return MasonryMetrics(width: gridWidth, columnWidth: pixelAlignedColumnWidth)
    }

    private func selectChannel(_ channel: String) {
        activeChannel = channel
        searchText = ""
        reloadToken += 1
    }

    private func submitSearch() {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            activeChannel = "今日灵感"
        } else {
            activeChannel = ""
        }
        reloadToken += 1
    }

    private func retry() {
        reloadToken += 1
    }

    private func reload() async {
        let query = resolvedQuery
        currentQuery = query
        currentPage = 0
        totalPages = 1
        posts = []
        loadState = .loading

        do {
            let page = try await client.searchPhotos(query: query, page: 1)
            guard !Task.isCancelled else {
                return
            }
            posts = page.posts.mergingFavoriteState(from: favoritePosts)
            currentPage = page.page
            totalPages = page.totalPages
            loadState = page.posts.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            return
        } catch UnsplashClientError.missingAccessKey {
            posts = []
            loadState = .missingKey
        } catch {
            posts = []
            loadState = .failed(error.localizedDescription)
        }
    }

    private func loadNextPage() async {
        guard !isLoadingMore, currentPage < totalPages, !currentQuery.isEmpty else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let page = try await client.searchPhotos(query: currentQuery, page: currentPage + 1)
            guard !Task.isCancelled else {
                return
            }
            posts.append(contentsOf: page.posts.mergingFavoriteState(from: favoritePosts))
            currentPage = page.page
            totalPages = page.totalPages
            loadState = posts.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            return
        } catch {
            loadState = posts.isEmpty ? .failed(error.localizedDescription) : .loaded
        }
    }

    private var resolvedQuery: String {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !keyword.isEmpty {
            return keywordQueries[keyword] ?? keyword
        }
        return channelQueries[activeChannel] ?? channelQueries["今日灵感"] ?? "creative photography illustration"
    }
}

private enum HomeLoadState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case missingKey
    case failed(String)
}

private struct MasonryMetrics {
    let width: CGFloat
    let columnWidth: CGFloat
}

private struct MasonryGrid: Layout {
    let columns: Int
    let spacing: CGFloat

    private var columnCount: Int {
        max(columns, 1)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableWidth = proposal.width ?? 0
        guard availableWidth > 0, !subviews.isEmpty else {
            return CGSize(width: availableWidth, height: 0)
        }

        let columnWidth = width(for: availableWidth)
        var heights = Array(repeating: CGFloat.zero, count: columnCount)

        for subview in subviews {
            let column = shortestColumn(in: heights)
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            heights[column] += size.height + spacing
        }

        return CGSize(width: availableWidth, height: max(0, (heights.max() ?? 0) - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard bounds.width > 0 else {
            return
        }

        let columnWidth = width(for: bounds.width)
        var heights = Array(repeating: CGFloat.zero, count: columnCount)

        for subview in subviews {
            let column = shortestColumn(in: heights)
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            let x = bounds.minX + CGFloat(column) * (columnWidth + spacing)
            let y = bounds.minY + heights[column]

            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: columnWidth, height: size.height)
            )

            heights[column] += size.height + spacing
        }
    }

    private func width(for availableWidth: CGFloat) -> CGFloat {
        max(0, (availableWidth - CGFloat(columnCount - 1) * spacing) / CGFloat(columnCount))
    }

    private func shortestColumn(in heights: [CGFloat]) -> Int {
        heights.enumerated().min { lhs, rhs in
            lhs.element < rhs.element
        }?.offset ?? 0
    }
}

private struct HomeHeader: View {
    @Binding var searchText: String
    @Binding var activeChannel: String

    let channels: [String]
    let onChannelSelected: (String) -> Void
    let onSearchSubmitted: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                BrandSpark()

                VStack(alignment: .leading, spacing: 3) {
                    Text("花火记")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(HuahuojiTheme.foreground)
                    Text("摄影 / 插画灵感")
                        .font(.system(size: 12))
                        .foregroundStyle(HuahuojiTheme.muted)
                }

                Spacer()

                CircleIconButton(systemName: "bell", accessibilityLabel: "通知")
            }

            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HuahuojiTheme.muted)

                TextField("搜索胶片、窗边光、拼贴…", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundStyle(HuahuojiTheme.foreground)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit(onSearchSubmitted)

                Text("推荐")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(HuahuojiTheme.muted)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(HuahuojiTheme.surface.opacity(0.58), in: Capsule())
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .glassCard(radius: 21)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(channels, id: \.self) { channel in
                        Button {
                            onChannelSelected(channel)
                        } label: {
                            Text(channel)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(activeChannel == channel ? HuahuojiTheme.foreground : HuahuojiTheme.muted)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    activeChannel == channel ? HuahuojiTheme.surface.opacity(0.82) : HuahuojiTheme.surface.opacity(0.48),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(HuahuojiTheme.surface.opacity(activeChannel == channel ? 0.76 : 0.5), lineWidth: 1)
                                )
                                .shadow(
                                    color: activeChannel == channel ? HuahuojiTheme.shadow.opacity(0.08) : .clear,
                                    radius: 10,
                                    y: 5
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct PostCard: View {
    @Binding var post: Post
    let cardWidth: CGFloat
    let tiltDegrees: Double
    let openAction: () -> Void
    let onFavoriteChanged: (Post) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: openAction) {
                RemoteArtImage(url: post.thumbnailURL, style: post.style, tiltDegrees: tiltDegrees)
                    .frame(width: cardWidth, height: imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .clipped()
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Button(action: openAction) {
                    Text(post.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineSpacing(2)
                        .foregroundStyle(HuahuojiTheme.foreground)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                HStack(spacing: 6) {
                    Button(action: openAction) {
                        HStack(spacing: 5) {
                            AvatarView(url: post.authorAvatarURL, size: 18)
                            Text(post.author)
                                .lineLimit(1)
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(HuahuojiTheme.muted)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 4)

                    LikeButton(post: $post, onFavoriteChanged: onFavoriteChanged)
                }
            }
            .frame(width: contentWidth)
            .padding(10)
        }
        .frame(width: cardWidth)
        .background(HuahuojiTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HuahuojiTheme.surface.opacity(0.68), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: HuahuojiTheme.shadow.opacity(0.06), radius: 8, y: 6)
    }

    private var imageHeight: CGFloat {
        cardWidth * post.thumbnailHeightRatio
    }

    private var contentWidth: CGFloat {
        max(0, cardWidth - 20)
    }
}

private struct LikeButton: View {
    @Binding var post: Post
    let onFavoriteChanged: (Post) -> Void

    var body: some View {
        Button {
            post.toggleFavorite()
            onFavoriteChanged(post)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: post.liked ? "heart.fill" : "heart")
                    .font(.system(size: 12, weight: .bold))
                Text("\(post.likes)")
                    .font(.system(size: 11, weight: .semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(post.liked ? HuahuojiTheme.accent : HuahuojiTheme.muted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(post.liked ? "取消收藏 \(post.title)" : "收藏 \(post.title)")
    }
}

private extension Array where Element == Post {
    func mergingFavoriteState(from favoritePosts: [Post]) -> [Post] {
        let favoritesByID = Dictionary(uniqueKeysWithValues: favoritePosts.map { ($0.id, $0) })

        return map { post in
            guard let favorite = favoritesByID[post.id] else {
                return post
            }

            var merged = post
            merged.liked = favorite.liked
            merged.likes = favorite.likes
            return merged
        }
    }
}

private struct LoadingSearchView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(HuahuojiTheme.accent)

            Text("正在加载灵感")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)

            Text("从 Unsplash 搜索摄影和插画图片。")
                .font(.system(size: 14))
                .foregroundStyle(HuahuojiTheme.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .padding(24)
        .glassCard(radius: 30)
    }
}

private struct HomeStatusView: View {
    let systemName: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemName)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(HuahuojiTheme.accent)

            Text(title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(HuahuojiTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 280)

            if let buttonTitle {
                Button(action: action) {
                    Label(buttonTitle, systemImage: "arrow.clockwise")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(HuahuojiTheme.surface)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(HuahuojiTheme.accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .padding(24)
        .glassCard(radius: 30)
    }
}

private struct LoadMoreView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint(HuahuojiTheme.accent)
            Text("继续加载")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(HuahuojiTheme.accent)

            Text("没有找到相关灵感")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)

            Text("换一个关键词试试，比如胶片、窗边光或拼贴。")
                .font(.system(size: 14))
                .foregroundStyle(HuahuojiTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .padding(24)
        .glassCard(radius: 30)
    }
}

private struct MissingPostView: View {
    var body: some View {
        ZStack {
            HuahuojiBackground()
            Text("这条灵感暂时不见了")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .padding(24)
                .glassCard(radius: 24)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
