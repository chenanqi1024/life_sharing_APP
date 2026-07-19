//
//  PublishView.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import PhotosUI
import SwiftUI
import UIKit

struct PublishView: View {
    @Binding var selectedTab: AppTab

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [ComposePhoto] = []
    @State private var title = ""
    @State private var detail = ""
    @State private var draftState = "草稿"
    @State private var publishButtonTitle = "发布"

    private let photoColumns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 3)

    var body: some View {
        ZStack {
            HuahuojiBackground()

            ScrollView {
                VStack(spacing: 16) {
                    topBar
                    composeCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: pickerItems) { _, newItems in
            Task {
                await loadPhotos(from: newItems)
            }
        }
        .onChange(of: title) { _, newValue in
            let trimmed = newValue.trimmedToHuahuojiByteLimit(40)
            if trimmed != newValue {
                title = trimmed
            }
            updateDraftState("编辑中")
        }
        .onChange(of: detail) { _, _ in
            updateDraftState("编辑中")
        }
    }

    private var topBar: some View {
        HStack {
            Button("取消") {
                selectedTab = .home
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(HuahuojiTheme.foreground)
            .frame(width: 68, height: 36)
            .background(HuahuojiTheme.surface.opacity(0.58), in: Capsule())
            .buttonStyle(.plain)

            Spacer()

            Text("发布灵感")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)

            Spacer()

            Text(draftState)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(HuahuojiTheme.muted)
                .frame(minWidth: 68, minHeight: 36)
                .background(HuahuojiTheme.surface.opacity(0.58), in: Capsule())
        }
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("添加图文")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuojiTheme.foreground)
                Text("上传多张图片，写下摄影 / 插画灵感的标题和详情。")
                    .font(.system(size: 13))
                    .lineSpacing(3)
                    .foregroundStyle(HuahuojiTheme.muted)
            }

            LazyVGrid(columns: photoColumns, spacing: 9) {
                ForEach(photos) { photo in
                    PhotoTile(photo: photo) {
                        removePhoto(photo)
                    }
                }

                PhotosPicker(selection: $pickerItems, maxSelectionCount: 9, matching: .images) {
                    PhotoAddTile()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("添加图片")
            }

            ComposeField(title: "标题", counter: "\(title.huahuojiByteLength)/40B") {
                TextField("例如：窗边蓝调光的一组速写", text: $title)
                    .font(.system(size: 15))
                    .foregroundStyle(HuahuojiTheme.foreground)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(HuahuojiTheme.surface.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1)
                    )
            }

            ComposeField(title: "详情", counter: "\(detail.count)") {
                TextEditor(text: $detail)
                    .font(.system(size: 15))
                    .foregroundStyle(HuahuojiTheme.foreground)
                    .frame(minHeight: 156)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(HuahuojiTheme.surface.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HuahuojiTheme.surface.opacity(0.72), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if detail.isEmpty {
                            Text("写下拍摄时间、灵感来源、配色或创作过程…")
                                .font(.system(size: 15))
                                .foregroundStyle(HuahuojiTheme.muted.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
            }

            HStack(spacing: 10) {
                Button("保存草稿") {
                    updateDraftState("已存草稿")
                }
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuojiTheme.foreground)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(HuahuojiTheme.surface.opacity(0.6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(HuahuojiTheme.surface.opacity(0.7), lineWidth: 1)
                )
                .buttonStyle(.plain)

                Button(publishButtonTitle) {
                    publish()
                }
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(canPublish ? HuahuojiTheme.surface : HuahuojiTheme.muted)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(canPublish ? HuahuojiTheme.accent : HuahuojiTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: canPublish ? HuahuojiTheme.accent.opacity(0.22) : .clear, radius: 12, y: 7)
                .buttonStyle(.plain)
                .disabled(!canPublish)
            }
        }
        .padding(16)
        .glassCard(radius: 30)
    }

    private var canPublish: Bool {
        !photos.isEmpty &&
        title.huahuojiByteLength > 0 &&
        title.huahuojiByteLength <= 40 &&
        !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var loadedPhotos: [ComposePhoto] = []

        for item in items {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                continue
            }
            loadedPhotos.append(ComposePhoto(image: image))
        }

        photos = loadedPhotos
        if !loadedPhotos.isEmpty {
            updateDraftState("已存草稿")
        }
    }

    private func removePhoto(_ photo: ComposePhoto) {
        photos.removeAll { $0.id == photo.id }
        updateDraftState("已存草稿")
    }

    private func updateDraftState(_ state: String) {
        if publishButtonTitle != "发布" {
            publishButtonTitle = "发布"
        }
        draftState = state
    }

    private func publish() {
        draftState = "已发布"
        publishButtonTitle = "发布成功"

        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            resetForm()
            selectedTab = .home
        }
    }

    private func resetForm() {
        pickerItems = []
        photos = []
        title = ""
        detail = ""
        draftState = "草稿"
        publishButtonTitle = "发布"
    }
}

private struct ComposePhoto: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage
}

private struct PhotoTile: View {
    let photo: ComposePhoto
    let removeAction: () -> Void

    var body: some View {
        SquarePhotoTile {
            GeometryReader { proxy in
                Image(uiImage: photo.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: removeAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(HuahuojiTheme.surface)
                    .frame(width: 26, height: 26)
                    .background(Color.black.opacity(0.5), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(6)
            .accessibilityLabel("删除图片")
        }
    }
}

private struct SquarePhotoTile<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PhotoAddTile: View {
    var body: some View {
        SquarePhotoTile {
            VStack(spacing: 7) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                Text("添加图片")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(HuahuojiTheme.muted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(HuahuojiTheme.surface.opacity(0.58))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(HuahuojiTheme.surface.opacity(0.72), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            )
        }
    }
}

private struct ComposeField<Content: View>: View {
    let title: String
    let counter: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuojiTheme.foreground)
                Spacer()
                Text(counter)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(HuahuojiTheme.muted)
            }

            content
        }
    }
}

private extension String {
    var huahuojiByteLength: Int {
        reduce(0) { total, character in
            let scalar = character.unicodeScalars.first?.value ?? 0
            return total + (scalar > 255 ? 2 : 1)
        }
    }

    func trimmedToHuahuojiByteLimit(_ limit: Int) -> String {
        var output = ""
        var count = 0

        for character in self {
            let scalar = character.unicodeScalars.first?.value ?? 0
            let size = scalar > 255 ? 2 : 1
            guard count + size <= limit else {
                break
            }
            output.append(character)
            count += size
        }

        return output
    }
}
