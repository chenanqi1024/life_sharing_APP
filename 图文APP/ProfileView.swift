//
//  ProfileView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            HuahuojiBackground()

            VStack {
                Spacer(minLength: 24)

                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 31, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [HuahuojiTheme.butter, HuahuojiTheme.rose],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "person")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(HuahuojiTheme.accent)
                        }
                        .frame(width: 88, height: 88)

                    Text("我的花火")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(HuahuojiTheme.foreground)

                    Text("这里先作为占位。后续可以放收藏夹、灵感分组和个人主页编辑。")
                        .font(.system(size: 14))
                        .foregroundStyle(HuahuojiTheme.muted)
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                }
                .frame(maxWidth: .infinity, minHeight: 498)
                .padding(24)
                .glassCard(radius: 34)
                .padding(.horizontal, 18)

                Spacer(minLength: 24)
            }
        }
    }
}

#Preview {
    ProfileView()
}
