//
//  ResponsePreset.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI

enum ResponsePreset: String, CaseIterable, Identifiable {
    case yesNo
    case thumbs
    case stars
    case smileys

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yesNo: return "Yes / No"
        case .thumbs: return "Thumbs"
        case .stars: return "Stars"
        case .smileys: return "Faces"
        }
    }

    var tileEmoji: String {
        switch self {
        case .yesNo: return "✅"
        case .thumbs: return "👍"
        case .stars: return "⭐️"
        case .smileys: return "😀"
        }
    }

    var defaultColumns: Int {
        switch self {
        case .yesNo: return 2
        case .thumbs: return 2
        case .stars: return 5
        case .smileys: return 5
        }
    }

    func buttonDefs() -> [PresetButtonDef] {
        let w: Float = 200
        let h: Float = 200

        switch self {
        case .yesNo:
            return [
                PresetButtonDef(
                    name: "yes",
                    title: "Yes",
                    sfSymbolName: "checkmark",
                    background: Color(red: 0.12, green: 0.78, blue: 0.28),
                    titleColor: .white,
                    width: w,
                    height: h
                ),
                PresetButtonDef(
                    name: "no",
                    title: "No",
                    sfSymbolName: "xmark",
                    background: Color(red: 0.92, green: 0.08, blue: 0.14),
                    titleColor: .white,
                    width: w,
                    height: h
                )
            ]
        case .thumbs:
            return [
                PresetButtonDef(
                    name: "up",
                    title: "",
                    emoji: "👍",
                    background: Color(red: 0.16, green: 0.70, blue: 0.28),
                    titleColor: .white,
                    width: w,
                    height: h),
                PresetButtonDef(
                    name: "down",
                    title: "",
                    emoji: "👎",
                    background: Color(red: 0.86, green: 0.20, blue: 0.20),
                    titleColor: .white,
                    width: w,
                    height: h),
            ]
        case .stars:
            return (1...5).map { n in
                PresetButtonDef(
                    name: "stars_\(n, default: "")",
                    title: "",
                    starsDiceCount: n, // <- dice layout (1..5)
                    background: Color(red: 0.98, green: 0.62, blue: 0.12),
                    titleColor: .white,
                    width: w,
                    height: h
                )
            }
        case .smileys:
            return [
                PresetButtonDef(
                    name: "great",
                    title: "Great!",
                    emoji: "😄",
                    background: Color(red: 0.18, green: 0.70, blue: 0.22),
                    titleColor: .white,
                    width: w,
                    height: h),
                PresetButtonDef(
                    name: "good",
                    title: "Good",
                    emoji: "🙂",
                    background: Color(red: 0.40, green: 0.78, blue: 0.20),
                    titleColor: .white,
                    width: w,
                    height: h),
                PresetButtonDef(
                    name: "okay",
                    title: "Okay",
                    emoji: "😐",
                    background: Color(red: 0.98, green: 0.78, blue: 0.10),
                    titleColor: .white,
                    width: w,
                    height: h),
                PresetButtonDef(
                    name: "bad",
                    title: "Bad",
                    emoji: "🙁",
                    background: Color(red: 0.98, green: 0.52, blue: 0.10),
                    titleColor: .white,
                    width: w,
                    height: h),
                PresetButtonDef(
                    name: "awful",
                    title: "Awful",
                    emoji: "😡",
                    background: Color(red: 0.92, green: 0.16, blue: 0.14),
                    titleColor: .white,
                    width: w,
                    height: h),
            ]
        }
    }
}
