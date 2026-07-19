//
//  ProfileView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

struct ProfileView: View {
    @Binding var favorites: [Post]
    let onFavoriteChanged: (Post) -> Void
    @State private var path: [Post.ID] = []

    private var favoriteIDs: [Post.ID] {
        favorites.filter(\.liked).map(\.id)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HuahuojiBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        ProfileHeader(favoriteCount: favoriteIDs.count)

                        if favoriteIDs.isEmpty {
                            FavoriteEmptyState()
                                .padding(.top, 6)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(favoriteIDs, id: \.self) { postID in
                                    if let post = binding(for: postID) {
                                        FavoritePostCard(post: post) {
                                            path.append(postID)
                                        } onFavoriteChanged: { post in
                                            onFavoriteChanged(post)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 112)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Post.ID.self) { postID in
                if let post = binding(for: postID) {
                    DetailView(post: post, onFavoriteChanged: onFavoriteChanged)
                } else {
                    MissingFavoriteView()
                }
            }
        }
    }

    private func binding(for postID: Post.ID) -> Binding<Post>? {
        guard let index = favorites.firstIndex(where: { $0.id == postID }) else {
            return nil
        }
        return $favorites[index]
    }
}

private struct ProfileHeader: View {
    let favoriteCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [HuahuojiTheme.butter, HuahuojiTheme.rose],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "person")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(HuahuojiTheme.accent)
                    }
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("我的花火")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(HuahuojiTheme.foreground)

                    Text("收藏的灵感会保存在这里")
                        .font(.system(size: 13))
                        .foregroundStyle(HuahuojiTheme.muted)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                FavoriteMetric(value: "\(favoriteCount)", title: "收藏")
                FavoriteMetric(value: "1", title: "灵感夹")
            }
        }
        .padding(16)
        .glassCard(radius: 28)
    }
}

private struct FavoriteMetric: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .frame(height: 58)
        .background(HuahuojiTheme.surface.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct FavoritePostCard: View {
    @Binding var post: Post
    let openAction: () -> Void
    let onFavoriteChanged: (Post) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: openAction) {
                HStack(spacing: 12) {
                    RemoteArtImage(url: post.thumbnailURL, style: post.style, tiltDegrees: -4)
                        .frame(width: 96, height: 116)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .clipped()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.title)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .lineSpacing(2)
                            .foregroundStyle(HuahuojiTheme.foreground)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)

                        HStack(spacing: 6) {
                            AvatarView(url: post.authorAvatarURL, size: 20)
                            Text(post.author)
                                .font(.system(size: 12))
                                .foregroundStyle(HuahuojiTheme.muted)
                                .lineLimit(1)
                        }

                        Text(post.sourceLabel)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(HuahuojiTheme.muted)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            FavoriteToggleButton(post: $post, onFavoriteChanged: onFavoriteChanged)
        }
        .padding(10)
        .background(HuahuojiTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HuahuojiTheme.surface.opacity(0.68), lineWidth: 1)
        )
        .shadow(color: HuahuojiTheme.shadow.opacity(0.08), radius: 16, y: 10)
    }
}

private struct FavoriteToggleButton: View {
    @Binding var post: Post
    let onFavoriteChanged: (Post) -> Void

    var body: some View {
        Button {
            post.toggleFavorite()
            onFavoriteChanged(post)
        } label: {
            Image(systemName: post.liked ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(post.liked ? HuahuojiTheme.accent : HuahuojiTheme.muted)
                .frame(width: 42, height: 42)
                .background(HuahuojiTheme.surface.opacity(0.58), in: Circle())
                .overlay(Circle().stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(post.liked ? "取消收藏 \(post.title)" : "收藏 \(post.title)")
    }
}

private struct FavoriteEmptyState: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(HuahuojiTheme.accent)

            Text("还没有收藏")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)

            Text("在图文详情页点亮爱心后，灵感会出现在这里。")
                .font(.system(size: 14))
                .foregroundStyle(HuahuojiTheme.muted)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, minHeight: 360)
        .padding(24)
        .glassCard(radius: 30)
    }
}

private struct MissingFavoriteView: View {
    var body: some View {
        ZStack {
            HuahuojiBackground()
            Text("这条收藏暂时不见了")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .padding(24)
                .glassCard(radius: 24)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    ProfileView(favorites: .constant(Post.samplePosts), onFavoriteChanged: { _ in })
}
