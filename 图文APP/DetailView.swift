//
//  DetailView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

struct DetailView: View {
    @Binding var post: Post
    var onFavoriteChanged: (Post) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DetailBackground()

            VStack(spacing: 0) {
                topBar

                ScrollView {
                    VStack(spacing: 10) {
                        hero
                        noteContent
                        comments
                    }
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(HuahuojiTheme.foreground)
                    .frame(width: 42, height: 42)
                    .background(HuahuojiTheme.surface.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(HuahuojiTheme.surface.opacity(0.76), lineWidth: 1))
                    .shadow(color: HuahuojiTheme.shadow.opacity(0.08), radius: 12, y: 7)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("返回首页")

            HStack(spacing: 9) {
                AvatarView(url: post.authorAvatarURL, size: 30)
                Text(post.author)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuojiTheme.foreground)
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            FollowButton()

            CircleIconButton(systemName: "ellipsis", accessibilityLabel: "更多")
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 9)
        .background(.ultraThinMaterial.opacity(0.55))
    }

    private var hero: some View {
        RemoteArtImage(url: post.detailImageURL ?? post.thumbnailURL, style: post.style, tiltDegrees: -5)
            .frame(height: 420)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(HuahuojiTheme.surface.opacity(0.78), lineWidth: 1)
            )
            .overlay(alignment: .bottom) {
                DotsIndicator()
                    .padding(.bottom, 14)
            }
            .shadow(color: HuahuojiTheme.shadow.opacity(0.12), radius: 22, y: 16)
    }

    private var noteContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    AvatarView(url: post.authorAvatarURL, size: 40)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(post.author)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(HuahuojiTheme.foreground)
                        Text(post.authorBio)
                            .font(.system(size: 12))
                            .foregroundStyle(HuahuojiTheme.muted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                FollowButton()
            }

            Text(post.title)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .lineSpacing(3)

            Text(post.copy)
                .font(.system(size: 14))
                .foregroundStyle(HuahuojiTheme.foreground)
                .lineSpacing(7)

            FlowTags(tags: post.tags)

            Text("\(post.timeText) · \(post.sourceLabel)")
                .font(.system(size: 12))
                .foregroundStyle(HuahuojiTheme.muted)
        }
        .padding(14)
        .glassCard(radius: 26)
    }

    private var comments: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("评论")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuojiTheme.foreground)
                Spacer()
                Text("\(post.comments.count) 条")
                    .font(.system(size: 12))
                    .foregroundStyle(HuahuojiTheme.muted)
            }

            ForEach(post.comments) { comment in
                HStack(alignment: .top, spacing: 9) {
                    AvatarView(size: 30)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(comment.name)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(HuahuojiTheme.foreground)
                        Text(comment.text)
                            .font(.system(size: 12))
                            .lineSpacing(3)
                            .foregroundStyle(HuahuojiTheme.foreground)
                        Text(comment.time)
                            .font(.system(size: 12))
                            .foregroundStyle(HuahuojiTheme.muted)
                    }
                }
            }
        }
        .padding(14)
        .glassCard(radius: 24)
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            Button("说点什么...") {}
                .font(.system(size: 13))
                .foregroundStyle(HuahuojiTheme.muted)
                .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                .padding(.horizontal, 14)
                .background(HuahuojiTheme.surface.opacity(0.62), in: Capsule())
                .overlay(Capsule().stroke(HuahuojiTheme.surface.opacity(0.74), lineWidth: 1))
                .buttonStyle(.plain)

            HStack(spacing: 8) {
                DetailActionButton(systemName: post.liked ? "heart.fill" : "heart", value: "\(post.likes)", isActive: post.liked) {
                    post.toggleFavorite()
                    onFavoriteChanged(post)
                }
                .accessibilityLabel(post.liked ? "取消收藏" : "收藏")

                DetailActionButton(systemName: "bubble.left", value: "\(post.comments.count)") {}
                    .accessibilityLabel("评论")

                DetailActionButton(systemName: "square.and.arrow.up", value: nil) {}
                    .accessibilityLabel("分享")
            }
        }
        .padding(9)
        .background(HuahuojiTheme.surface.opacity(0.78), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1)
        )
        .shadow(color: HuahuojiTheme.shadow.opacity(0.14), radius: 22, y: 14)
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 7) {
                tagContent
            }

            VStack(alignment: .leading, spacing: 7) {
                tagContent
            }
        }
    }

    @ViewBuilder
    private var tagContent: some View {
        ForEach(tags, id: \.self) { tag in
            Text(tag)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(HuahuojiTheme.surface.opacity(0.58), in: Capsule())
                .overlay(Capsule().stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1))
        }
    }
}

private struct DetailActionButton: View {
    let systemName: String
    let value: String?
    var isActive = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemName)
                    .font(.system(size: 19, weight: .semibold))
                if let value {
                    Text(value)
                        .font(.system(size: 11, weight: .heavy))
                        .monospacedDigit()
                }
            }
            .foregroundStyle(isActive ? HuahuojiTheme.accent : HuahuojiTheme.foreground)
            .frame(minWidth: 40, minHeight: 42)
        }
        .buttonStyle(.plain)
    }
}
