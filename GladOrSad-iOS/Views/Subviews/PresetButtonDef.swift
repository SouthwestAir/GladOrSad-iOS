//
//  PresetButtonDef.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI

struct PresetButtonDef {
    let name: String
    let title: String
    let emoji: String?             // thumbs/smileys
    let sfSymbolName: String?      // yes/no icons
    let starsDiceCount: Int?       // 1..5 (dice layout)
    let background: Color
    let titleColor: Color
    let width: Float
    let height: Float

    init(
        name: String,
        title: String,
        emoji: String? = nil,
        sfSymbolName: String? = nil,
        starsDiceCount: Int? = nil,
        background: Color,
        titleColor: Color,
        width: Float,
        height: Float
    ) {
        self.name = name
        self.title = title
        self.emoji = emoji
        self.sfSymbolName = sfSymbolName
        self.starsDiceCount = starsDiceCount
        self.background = background
        self.titleColor = titleColor
        self.width = width
        self.height = height
    }

    var imagePNGData: Data? {
        if let c = starsDiceCount { return starsDicePNG(count: c) }
        if let s = sfSymbolName { return symbolPNG(systemName: s) }
        if let e = emoji { return emojiPNG(e) }
        return nil
    }

    // MARK: - SF Symbol icon renderer (for Yes/No)

    private func symbolPNG(systemName: String, size: CGSize = CGSize(width: 180, height: 180)) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let cfg = UIImage.SymbolConfiguration(pointSize: 110, weight: .bold)
        guard let base = UIImage(systemName: systemName, withConfiguration: cfg) else { return nil }
        let icon = base.withTintColor(.white, renderingMode: .alwaysOriginal)

        let img = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            ctx.cgContext.setShadow(
                offset: CGSize(width: 0, height: 3),
                blur: 10,
                color: UIColor.black.withAlphaComponent(0.30).cgColor
            )

            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                .insetBy(dx: 24, dy: 24)

            icon.draw(in: rect)
        }

        return img.pngData()
    }

    // MARK: - Dice-layout stars renderer (1..5)

    private func starsDicePNG(count: Int, size: CGSize = CGSize(width: 180, height: 180)) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let cfg = UIImage.SymbolConfiguration(pointSize: 46, weight: .semibold)
        guard let base = UIImage(systemName: "star.fill", withConfiguration: cfg) else { return nil }
        let star = base.withTintColor(.white, renderingMode: .alwaysOriginal)

        let starBox: CGFloat = 52  // drawing box size
        let positions = dicePositions(for: max(1, min(count, 5))) // 1..5

        let img = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            ctx.cgContext.setShadow(
                offset: CGSize(width: 0, height: 3),
                blur: 10,
                color: UIColor.black.withAlphaComponent(0.28).cgColor
            )

            for p in positions {
                let x = size.width * p.x - starBox / 2
                let y = size.height * p.y - starBox / 2
                star.draw(in: CGRect(x: x, y: y, width: starBox, height: starBox))
            }
        }

        return img.pngData()
    }

    private func dicePositions(for count: Int) -> [CGPoint] {
        // normalized (0..1) positions like dice pips
        let tl = CGPoint(x: 0.30, y: 0.30)
        let tr = CGPoint(x: 0.70, y: 0.30)
        let bl = CGPoint(x: 0.30, y: 0.70)
        let br = CGPoint(x: 0.70, y: 0.70)
        let c  = CGPoint(x: 0.50, y: 0.50)

        switch count {
        case 1: return [c]
        case 2: return [tl, br]
        case 3: return [tl, c, br]
        case 4: return [tl, tr, bl, br]
        default: return [tl, tr, c, bl, br] // 5
        }
    }

    // MARK: - Emoji renderer

    private func emojiPNG(_ text: String) -> Data? {
        let size = CGSize(width: 180, height: 180)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { _ in
            UIColor.clear.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))

            let str = NSString(string: text)
            let font = UIFont.systemFont(ofSize: 110)
            let attrs: [NSAttributedString.Key: Any] = [.font: font]

            let textSize = str.size(withAttributes: attrs)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            str.draw(in: rect, withAttributes: attrs)
        }
        return img.pngData()
    }
}
