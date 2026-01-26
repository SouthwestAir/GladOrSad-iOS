//
//  ResponseDraft.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI

struct ResponseDraft {
    var name: String = ""
    var title: String = ""
    var titleColor: Color = .white
    var background: Color = .black
    var width: Double = 200
    var height: Double = 200

    // Icon
    var replaceIcon: Bool = true
    var iconSource: ResponseIconSource = .emoji
    var emoji: String = "😀"
    var sfSymbol: String = "star.fill"

    mutating func load(from button: SettingsButton) {
        name = button.name ?? ""
        title = button.title ?? ""
        titleColor = Color(hex: button.titleColor ?? "FFFFFF") ?? .white
        background = Color(hex: button.background ?? "000000") ?? .black
        width = Double(button.width)
        height = Double(button.height)

        // For edits: default is "don’t touch icon unless user wants to"
        replaceIcon = false
        iconSource = .none
        emoji = "😀"
        sfSymbol = "star.fill"
    }
}
