//
//  ResponseEditorPane.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI
import CoreData
import UIKit

struct ResponseEditorPane: View {
    @Environment(\.managedObjectContext) private var dataContext

    // Selection / mode
    @Binding var selected: SettingsButton?
    @Binding var isAdding: Bool

    // Needed for new button index
    var nextIndex: Int

    // Callbacks
    var onSaved: (() -> Void)? = nil
    var onDeleted: (() -> Void)? = nil

    @State private var draft = ResponseDraft()
    @State private var currentIconPreview: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if selected == nil && !isAdding {
                emptyState
            } else {
                editorForm
            }
        }
        .onAppear { refreshDraft() }
        .onChange(of: selected?.objectID) { _ in refreshDraft() }
        .onChange(of: isAdding) { _ in refreshDraft() }
    }

    private var header: some View {
        HStack {
            Text(isAdding ? "Add Response" : "Edit Response")
                .font(.headline)
                .foregroundColor(Color("SWA-MidnightBlue"))

            Spacer()

            if selected != nil || isAdding {
                Button("Cancel") {
                    selected = nil
                    isAdding = false
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select a response to edit")
                .font(.headline)
                .foregroundColor(Color("SWA-MidnightBlue"))
            Text("Or tap “Add Response” to create a new one.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var editorForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                section("Basics") {
                    labeled("Internal name") {
                        TextField("e.g. happy / sad / stars_5", text: $draft.name)
                            .textFieldStyle(.roundedBorder)
                    }

                    labeled("Title (optional)") {
                        TextField("Shown under the icon", text: $draft.title)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                section("Colors") {
                    HStack {
                        Text("Background").foregroundColor(Color("SWA-MidnightBlue"))
                        Spacer()
                        ColorPicker("", selection: $draft.background).labelsHidden()
                    }
                    HStack {
                        Text("Title color").foregroundColor(Color("SWA-MidnightBlue"))
                        Spacer()
                        ColorPicker("", selection: $draft.titleColor).labelsHidden()
                    }
                }

                section("Size") {
                    HStack {
                        Text("Width").foregroundColor(Color("SWA-MidnightBlue"))
                        Spacer()
                        Stepper(value: $draft.width, in: 120...360, step: 10) {
                            Text("\(Int(draft.width))")
                                .font(.headline)
                                .foregroundColor(Color("SWA-MidnightBlue"))
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                    HStack {
                        Text("Height").foregroundColor(Color("SWA-MidnightBlue"))
                        Spacer()
                        Stepper(value: $draft.height, in: 120...360, step: 10) {
                            Text("\(Int(draft.height))")
                                .font(.headline)
                                .foregroundColor(Color("SWA-MidnightBlue"))
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }

                section("Icon") {
                    if let existing = selected, let data = existing.image, let ui = UIImage(data: data) {
                        HStack(spacing: 12) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .padding(8)
                                .background(Color.black.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current icon")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Color("SWA-MidnightBlue"))
                                Text("Choose Emoji or SF Symbol to replace it.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }

                    if selected != nil {
                        Toggle("Replace icon", isOn: $draft.replaceIcon)
                            .tint(Color("SWA-BoldBlue"))
                    }

                    Picker("Source", selection: $draft.iconSource) {
                        ForEach(ResponseIconSource.allCases) { src in
                            Text(src.rawValue).tag(src)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(selected != nil && draft.replaceIcon == false)

                    Group {
                        switch draft.iconSource {
                        case .none:
                            EmptyView()

                        case .emoji:
                            labeled("Emoji") {
                                TextField("😀", text: $draft.emoji)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 22))
                                    .onChange(of: draft.emoji) { _ in updateIconPreview() }
                            }

                        case .sfSymbol:
                            labeled("SF Symbol name") {
                                TextField("e.g. star.fill", text: $draft.sfSymbol)
                                    .textFieldStyle(.roundedBorder)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .onChange(of: draft.sfSymbol) { _ in updateIconPreview() }
                            }

                            commonSymbolsRow
                        }
                    }
                    .opacity((selected != nil && draft.replaceIcon == false) ? 0.4 : 1.0)
                    .disabled(selected != nil && draft.replaceIcon == false)

                    if let ui = currentIconPreview {
                        HStack(spacing: 12) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .padding(8)
                                .background(Color.black.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            Text("New icon preview")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Color("SWA-MidnightBlue"))
                            Spacer()
                        }
                    }

                    if selected != nil {
                        Button(role: .destructive) {
                            selected?.image = nil
                            try? dataContext.save()
                            onSaved?()
                        } label: {
                            Text("Clear icon")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        save()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("SWA-SunriseYellow"))
                    .foregroundColor(Color("SWA-MidnightBlue"))

                    if selected != nil {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.red.opacity(0.85))
                    }
                }
                .padding(.top, 6)
            }
            .padding(.bottom, 12)
        }
    }

    private var commonSymbolsRow: some View {
    
        let symbols = [
            "airplane.departure", "airplane", "airplane.arrival",
            "wifi", "cellularbars",
            "suitcase.rolling.fill", "bag.fill",
            "person.2.fill", "figure.walk",
            "ticket.fill", "qrcode",
            "mappin.and.ellipse",
            "clock.fill",
            "fork.knife",
            "cup.and.saucer.fill",
            "headphones",
            "questionmark.circle.fill", "info.circle.fill",
            "checkmark.circle.fill", "xmark.circle.fill",
            "heart.fill"
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(symbols, id: \.self) { s in
                    Button {
                        draft.sfSymbol = s
                        updateIconPreview()
                    } label: {
                        Image(systemName: s)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 40, height: 36)
                            .background(Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Helpers

    private func refreshDraft() {
        if isAdding {
            draft = ResponseDraft()
            draft.replaceIcon = true
            draft.iconSource = .emoji
            currentIconPreview = renderEmojiPNG(draft.emoji)
            return
        }

        if let b = selected {
            draft = ResponseDraft()
            draft.load(from: b)
            currentIconPreview = nil
            return
        }

        draft = ResponseDraft()
        currentIconPreview = nil
    }

    private func updateIconPreview() {
        guard selected == nil || draft.replaceIcon else {
            currentIconPreview = nil
            return
        }
        switch draft.iconSource {
        case .none:
            currentIconPreview = nil
        case .emoji:
            currentIconPreview = renderEmojiPNG(draft.emoji)
        case .sfSymbol:
            currentIconPreview = renderSymbolPNG(draft.sfSymbol)
        }
    }

    private func save() {
        if isAdding {
            let b = SettingsButton(context: dataContext)
            b.id = UUID()
            b.index = Int16(nextIndex)
            applyDraft(to: b)

            do {
                try dataContext.save()
                selected = b
                isAdding = false
                onSaved?()
            } catch {
                print("Failed saving new response: \(error)")
            }
            return
        }

        if let b = selected {
            applyDraft(to: b)
            do {
                try dataContext.save()
                onSaved?()
            } catch {
                print("Failed saving response: \(error)")
            }
        }
    }

    private func delete() {
        if let b = selected {
            dataContext.delete(b)
            do {
                try dataContext.save()
                selected = nil
                isAdding = false
                onDeleted?()
            } catch {
                print("Failed deleting response: \(error)")
            }
        }
    }

    private func applyDraft(to b: SettingsButton) {
        b.name = draft.name
        b.title = draft.title
        b.titleColor = draft.titleColor.toHex()
        b.background = draft.background.toHex()
        b.width = Float(draft.width)
        b.height = Float(draft.height)

        // Icon writing rules
        let shouldWriteIcon = (selected == nil) || draft.replaceIcon
        if shouldWriteIcon {
            switch draft.iconSource {
            case .none:
                break // don't change
            case .emoji:
                b.image = renderEmojiPNG(draft.emoji)?.pngData()
            case .sfSymbol:
                b.image = renderSymbolPNG(draft.sfSymbol)?.pngData()
            }
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("SWA-MidnightBlue"))
            content()
        }
        .padding(12)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func labeled(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color("SWA-MidnightBlue"))
            content()
        }
    }

    // MARK: - Renderers

    private func renderEmojiPNG(_ emoji: String) -> UIImage? {
        let text = emoji.isEmpty ? "😀" : emoji
        let size = CGSize(width: 180, height: 180)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            UIColor.clear.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let str = NSString(string: text)
            let font = UIFont.systemFont(ofSize: 110)
            let attrs: [NSAttributedString.Key: Any] = [.font: font]
            let ts = str.size(withAttributes: attrs)
            let rect = CGRect(x: (size.width - ts.width)/2, y: (size.height - ts.height)/2, width: ts.width, height: ts.height)
            str.draw(in: rect, withAttributes: attrs)
        }
    }

    private func renderSymbolPNG(_ name: String) -> UIImage? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let tint = UIColor(draft.titleColor) // <- key change
        let size = CGSize(width: 180, height: 180)
        let renderer = UIGraphicsImageRenderer(size: size)

        let cfg = UIImage.SymbolConfiguration(pointSize: 110, weight: .bold)
        guard let base = UIImage(systemName: trimmed, withConfiguration: cfg) else { return nil }
        let icon = base.withTintColor(tint, renderingMode: .alwaysOriginal)

        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            ctx.cgContext.setShadow(offset: CGSize(width: 0, height: 3),
                                    blur: 10,
                                    color: UIColor.black.withAlphaComponent(0.30).cgColor)
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 24, dy: 24)
            icon.draw(in: rect)
        }
    }

}
