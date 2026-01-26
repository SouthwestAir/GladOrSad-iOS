//
//  PresetTile.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI

struct PresetTile: View {
    let preset: ResponsePreset
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(preset.tileEmoji)
                    .font(.system(size: 34))
                    .frame(width: 56, height: 44)

                Text(preset.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color("SWA-MidnightBlue"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
