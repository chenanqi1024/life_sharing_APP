//
//  HomeView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var posts: [Post]
    @State private var path: [Post.ID] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(posts: $posts) { postID in
                path.append(postID)
            }
            .navigationDestination(for: Post.ID.self) { postID in
                if let post = binding(for: postID) {
                    DetailView(post: post)
                } else {
                    MissingPostView()
                }
            }
        }
    }

    private func binding(for postID: Post.ID) -> Binding<Post>? {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else {
            return nil
        }
        return $posts[index]
    }
}

struct HomeView: View {
    @Binding var posts: [Post]
    let openPost: (Post.ID) -> Void

    @State private var searchText = ""
    @State private var activeChannel = "今日灵感"

    private let channels = ["今日灵感", "摄影", "插画", "胶片感", "配色"]

    var body: some View {
        ZStack {
            HuahuojiBackground()

            VStack(spacing: 0) {
                HomeHeader(
                    searchText: $searchText,
                    activeChannel: $activeChannel,
                    channels: channels,
                    onChannelSelected: selectChannel
                )
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 10)

                if filteredPosts.isEmpty {
                    EmptySearchView()
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                } else {
                    ScrollView {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(Array(columns.enumerated()), id: \.offset) { _, column in
                                LazyVStack(spacing: 12) {
                                    ForEach(column) { entry in
                                        if let post = binding(for: entry.postID) {
                                            PostCard(post: post, tiltDegrees: entry.tiltDegrees) {
                                                openPost(entry.postID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 28)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var filteredPosts: [Post] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !keyword.isEmpty else {
            return posts
        }
        return posts.filter { post in
            "\(post.title) \(post.author) \(post.copy)".lowercased().contains(keyword)
        }
    }

    private var columns: [[MasonryEntry]] {
        var result: [[MasonryEntry]] = [[], []]
        var heights = [0.0, 0.0]

        for (displayIndex, post) in filteredPosts.enumerated() {
            let target = heights[0] <= heights[1] ? 0 : 1
            result[target].append(MasonryEntry(postID: post.id, displayIndex: displayIndex))
            heights[target] += post.heightWeight
        }

        return result
    }

    private func binding(for postID: Post.ID) -> Binding<Post>? {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else {
            return nil
        }
        return $posts[index]
    }

    private func selectChannel(_ channel: String) {
        activeChannel = channel
        searchText = channel == "今日灵感" ? "" : channel
    }
}

private struct MasonryEntry: Identifiable {
    let postID: Post.ID
    let displayIndex: Int

    var id: Post.ID { postID }
    var tiltDegrees: Double { displayIndex.isMultiple(of: 2) ? -5 : 5 }
}

private struct HomeHeader: View {
    @Binding var searchText: String
    @Binding var activeChannel: String

    let channels: [String]
    let onChannelSelected: (String) -> Void

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
    let tiltDegrees: Double
    let openAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: openAction) {
                ArtPreview(style: post.style, tiltDegrees: tiltDegrees)
                    .aspectRatio(1 / post.size.heightRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
                            AvatarView(size: 18)
                            Text(post.author)
                                .lineLimit(1)
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(HuahuojiTheme.muted)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 4)

                    LikeButton(post: $post)
                }
            }
            .padding(10)
        }
        .background(HuahuojiTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HuahuojiTheme.surface.opacity(0.68), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: HuahuojiTheme.shadow.opacity(0.09), radius: 16, y: 10)
    }
}

private struct LikeButton: View {
    @Binding var post: Post

    var body: some View {
        Button {
            post.liked.toggle()
            post.likes += post.liked ? 1 : -1
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
        .accessibilityLabel(post.liked ? "取消喜欢 \(post.title)" : "喜欢 \(post.title)")
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
