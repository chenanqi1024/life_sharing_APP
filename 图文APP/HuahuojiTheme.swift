//
//  HuahuojiTheme.swift
//  图文APP
//
//  Created by Codex on 2026/7/19.
//

import SwiftUI

enum HuahuojiTheme {
    static let background = Color(hex: 0xFFF4FD)
    static let surface = Color(hex: 0xFFFFFF)
    static let foreground = Color(hex: 0x1A1E2D)
    static let muted = Color(hex: 0x70778C)
    static let border = Color(hex: 0xE3DEEE)
    static let accent = Color(hex: 0xDE667A)
    static let mint = Color(hex: 0xABEBD3)
    static let sky = Color(hex: 0xB1E4F9)
    static let lilac = Color(hex: 0xE4CCFA)
    static let butter = Color(hex: 0xF7E4AB)
    static let peach = Color(hex: 0xFFC6AD)
    static let rose = Color(hex: 0xFFCBD6)
    static let shadow = Color(hex: 0x3F3F5C)

    static func gradient(for style: PostStyle) -> LinearGradient {
        switch style {
        case .studio:
            LinearGradient(colors: [rose, butter, mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .window:
            LinearGradient(colors: [sky, surface, lilac], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .film:
            LinearGradient(colors: [peach, rose, lilac], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .garden:
            LinearGradient(colors: [mint, butter, sky], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .desk:
            LinearGradient(colors: [lilac, surface, rose], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .night:
            LinearGradient(colors: [sky, lilac, rose], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
