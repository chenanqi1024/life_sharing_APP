//
//  ContentView.swift
//  图文APP
//
//  Created by chenanqi on 2026/7/19.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case publish
    case profile

    var id: String { rawValue }

    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label("首页", systemImage: "house")
        case .publish:
            Label("发布", systemImage: "plus")
        case .profile:
            Label("我的", systemImage: "person")
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var posts: [Post] = []
    @State private var favoritePosts: [Post] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView(
                posts: $posts,
                favoritePosts: favoritePosts,
                onFavoriteChanged: handleFavoriteChange
            )
                .tabItem { AppTab.home.label }
                .tag(AppTab.home)

            PublishView(selectedTab: $selectedTab)
                .tabItem { AppTab.publish.label }
                .tag(AppTab.publish)

            ProfileView(favorites: $favoritePosts, onFavoriteChanged: handleFavoriteChange)
                .tabItem { AppTab.profile.label }
                .tag(AppTab.profile)
        }
        .tint(HuahuojiTheme.accent)
    }

    private func handleFavoriteChange(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].liked = post.liked
            posts[index].likes = post.likes
        }

        if let index = favoritePosts.firstIndex(where: { $0.id == post.id }) {
            favoritePosts[index] = post
        } else if post.liked {
            favoritePosts.insert(post, at: 0)
        }
    }
}

#Preview {
    ContentView()
}
