//
//  HuahuojiComponents.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI
import NukeUI

struct HuahuojiBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [HuahuojiTheme.rose, HuahuojiTheme.sky, HuahuojiTheme.butter],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(HuahuojiTheme.butter.opacity(0.65))
                .frame(width: 240, height: 240)
                .blur(radius: 44)
                .offset(x: -150, y: -300)

            Circle()
                .fill(HuahuojiTheme.lilac.opacity(0.56))
                .frame(width: 230, height: 230)
                .blur(radius: 48)
                .offset(x: 160, y: -260)

            Circle()
                .fill(HuahuojiTheme.mint.opacity(0.56))
                .frame(width: 260, height: 260)
                .blur(radius: 54)
                .offset(x: -150, y: 320)
        }
        .ignoresSafeArea()
    }
}

struct DetailBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [HuahuojiTheme.lilac, HuahuojiTheme.butter, HuahuojiTheme.rose],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(HuahuojiTheme.rose.opacity(0.64))
                .frame(width: 220, height: 220)
                .blur(radius: 46)
                .offset(x: -150, y: -300)

            Circle()
                .fill(HuahuojiTheme.mint.opacity(0.58))
                .frame(width: 240, height: 240)
                .blur(radius: 50)
                .offset(x: 150, y: -220)

            Circle()
                .fill(HuahuojiTheme.sky.opacity(0.58))
                .frame(width: 280, height: 280)
                .blur(radius: 58)
                .offset(x: -80, y: 360)
        }
        .ignoresSafeArea()
    }
}

struct BrandSpark: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [HuahuojiTheme.accent, HuahuojiTheme.peach],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(HuahuojiTheme.surface)
                    .frame(width: 9, height: 9)
                    .offset(x: 12, y: 10)
            }
            .frame(width: 36, height: 36)
            .shadow(color: HuahuojiTheme.accent.opacity(0.22), radius: 12, y: 7)
    }
}

struct AvatarView: View {
    var url: URL?
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [HuahuojiTheme.sky, HuahuojiTheme.rose],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let url {
                LazyImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.18))) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity)
                    }
                }
            }
        }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(HuahuojiTheme.surface.opacity(0.75), lineWidth: max(1, size / 20)))
    }
}

struct CircleIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(HuahuojiTheme.foreground)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(HuahuojiTheme.surface.opacity(0.68), lineWidth: 1))
                .shadow(color: HuahuojiTheme.shadow.opacity(0.08), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct FollowButton: View {
    var body: some View {
        Button("关注") {}
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(HuahuojiTheme.surface)
            .padding(.horizontal, 13)
            .frame(height: 34)
            .background(HuahuojiTheme.accent, in: Capsule())
            .shadow(color: HuahuojiTheme.accent.opacity(0.2), radius: 10, y: 6)
            .buttonStyle(.plain)
    }
}

struct ArtPreview: View {
    let style: PostStyle
    var tiltDegrees: Double = -5

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HuahuojiTheme.gradient(for: style)

                Circle()
                    .fill(HuahuojiTheme.surface.opacity(0.52))
                    .frame(width: proxy.size.width * 0.62)
                    .offset(x: proxy.size.width * 0.38, y: -proxy.size.height * 0.35)

                Circle()
                    .fill(HuahuojiTheme.surface.opacity(0.4))
                    .frame(width: proxy.size.width * 0.36)
                    .offset(x: -proxy.size.width * 0.3, y: proxy.size.height * 0.28)

                SceneCard(tiltDegrees: tiltDegrees)
                    .frame(width: proxy.size.width * 0.76, height: proxy.size.height * 0.66)
            }
        }
    }
}

struct RemoteArtImage: View {
    let url: URL?
    let style: PostStyle
    var tiltDegrees: Double = -5

    var body: some View {
        LazyImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.22))) { state in
            ZStack {
                ArtPreview(style: style, tiltDegrees: tiltDegrees)

                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                } else if state.error != nil {
                    Image(systemName: "photo")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(HuahuojiTheme.surface.opacity(0.9))
                        .padding(14)
                        .background(HuahuojiTheme.foreground.opacity(0.2), in: Circle())
                } else {
                    ProgressView()
                        .tint(HuahuojiTheme.accent)
                }
            }
        }
    }
}

private struct SceneCard: View {
    let tiltDegrees: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [HuahuojiTheme.surface.opacity(0.42), HuahuojiTheme.surface.opacity(0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 2)
            }
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(HuahuojiTheme.peach.opacity(0.68))
                    .frame(height: 32)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 22)
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(HuahuojiTheme.butter.opacity(0.9))
                    .frame(width: 22, height: 22)
                    .padding(.top, 20)
                    .padding(.trailing, 24)
                    .shadow(color: HuahuojiTheme.surface.opacity(0.4), radius: 0)
            }
            .rotationEffect(.degrees(tiltDegrees))
            .shadow(color: HuahuojiTheme.shadow.opacity(0.08), radius: 18, y: 12)
    }
}

struct DotsIndicator: View {
    var body: some View {
        HStack(spacing: 5) {
            Capsule()
                .fill(HuahuojiTheme.surface.opacity(0.92))
                .frame(width: 16, height: 6)
            Circle()
                .fill(HuahuojiTheme.surface.opacity(0.58))
                .frame(width: 6, height: 6)
            Circle()
                .fill(HuahuojiTheme.surface.opacity(0.58))
                .frame(width: 6, height: 6)
        }
    }
}

extension View {
    func glassCard(radius: CGFloat = 22) -> some View {
        self
            .background(HuahuojiTheme.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(HuahuojiTheme.surface.opacity(0.68), lineWidth: 1)
            )
            .shadow(color: HuahuojiTheme.shadow.opacity(0.08), radius: 18, y: 10)
    }
}
