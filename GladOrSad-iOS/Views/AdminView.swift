//
//  AdminView.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/3/23.
//  Rebuilt by Jeffrey Berthiaume on 1/20/26.
//

import SwiftUI
import CoreData
import UIKit

struct AdminView: View {
    @Environment(\.managedObjectContext) private var dataContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\SettingsButton.index, order: .forward)],
        predicate: nil,
        animation: .default
    )
    private var settingsButtonsList: FetchedResults<SettingsButton>

    @ObservedObject var settingsViewModel: SettingsViewModel
    @StateObject private var versionViewModel = VersionViewModel()

    // UI state
    @State private var selectedTab: AdminTab = .content
    @State private var previewSelectedButtonID: UUID? = nil

    // Preset overwrite warning
    @State private var pendingPreset: ResponsePreset? = nil
    @State private var presetOverwriteAlertShowing = false

    // Save/export/data
    @State private var settingsSavedAlertShowing = false
    @State private var exportConfirmAlertShowing = false
    @State private var dataExportResultShowing = false
    @State private var dataExportResultMessage = ""
    @State private var showDataSheet = false

    // Responses edit mode (for reorder)
    @State private var responsesEditMode: EditMode = .inactive
    
    @State private var selectedResponse: SettingsButton? = nil
    @State private var isAddingResponse: Bool = false
    @State private var compactShowEditor: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient.ignoresSafeArea()

                let isLandscape = geo.size.width > geo.size.height
                if isLandscape {
                    HStack(spacing: 18) {
                        previewPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        inspectorPane
                            .frame(width: min(520, max(380, geo.size.width * 0.38)))
                    }
                    .padding(18)
                } else {
                    VStack(spacing: 14) {
                        previewPane
                            .frame(maxWidth: .infinity)
                            .frame(height: min(520, geo.size.height * 0.48))

                        inspectorPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(14)
                }
            }
        }
        .tint(Color("SWA-BoldBlue"))
        .navigationTitle("Admin")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveSettings(showConfirmation: false)
                    dismiss()
                }
                .fontWeight(.bold)
            }
        }
        .sheet(isPresented: $showDataSheet) {
            VStack {
                DataView()

                HStack(spacing: 12) {
                    Button("Copy to Clipboard") {
                        if let data = UploadDataManager.shared.csvData {
                            UIPasteboard.general.string = data
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("SWA-SunriseYellow"))
                    .foregroundColor(Color("SWA-MidnightBlue"))

                    Button("Close") {
                        showDataSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("SWA-SunriseYellow"))
                    .foregroundColor(Color("SWA-MidnightBlue"))
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .alert("Saved", isPresented: $settingsSavedAlertShowing) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Settings updated.")
        }
        .alert("Export Data", isPresented: $exportConfirmAlertShowing) {
            Button("Export & Clear", role: .destructive) {
                exportData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Export quiz data and clear local quiz data storage?")
        }
        .alert("Data Export", isPresented: $dataExportResultShowing) {
            Button("OK", role: .cancel) {
                // optional: dismiss after export result
                dismiss()
            }
        } message: {
            Text(dataExportResultMessage)
        }
        .alert("Overwrite Responses?", isPresented: $presetOverwriteAlertShowing) {
            Button("Overwrite", role: .destructive) {
                if let preset = pendingPreset {
                    applyPreset(preset)
                }
                pendingPreset = nil
            }
            Button("Cancel", role: .cancel) {
                pendingPreset = nil
            }
        } message: {
            Text("Selecting a preset will replace your existing buttons. This can’t be undone.")
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color("SWA-BoldBlue"),
                Color("SWA-MidnightBlue")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(Color.black.opacity(0.10))
    }

    // MARK: - Preview Pane

    private var previewPane: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Preview")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                // Optional tiny hint
                Text("Tap a response to highlight")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.65))
            }

            previewCard
        }
    }
    
    private func previewResponseButton(_ button: SettingsButton, baseSize: CGSize) -> some View {
        let isSelected = (previewSelectedButtonID == button.id)
        let bg = Color(hex: button.background ?? "000000") ?? .black
        let titleColor = Color(hex: button.titleColor ?? "FFFFFF") ?? .white

        return Button {
            previewSelectedButtonID = button.id
        } label: {
            VStack(spacing: 8) {
                let hasTitle = !((button.title ?? "").isEmpty)
                let iconWidth = hasTitle ? baseSize.width * 0.46 : baseSize.width * 0.80

                if let data = button.image, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconWidth)
                        .padding(.top, hasTitle ? 6 : 0)
                        .opacity(isSelected ? 0.70 : 1.0)
                }

                if let title = button.title, !title.isEmpty {
                    Text(title)
                        .font(.custom("SouthwestSans-Bold", size: 28))
                        .foregroundColor(titleColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
            }
            .frame(width: baseSize.width, height: baseSize.height)
            .background(
                Circle()
                    .fill(bg.opacity(isSelected ? 0.78 : 1.0))
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(isSelected ? 0.85 : 0.14),
                            lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private var previewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )

            // Inner quiz preview
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(settingsViewModel.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(spacing: 16) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text(settingsViewModel.caption.isEmpty ? " " : settingsViewModel.caption)
                            .font(.title3.weight(.bold))
                            .foregroundColor(settingsViewModel.captionColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)

                        Text(settingsViewModel.prompt.isEmpty ? " " : settingsViewModel.prompt)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(settingsViewModel.promptColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                    }
                    .padding(.top, 18)

                    if settingsButtonsList.isEmpty {
                        emptyResponsesPlaceholder
                            .padding(.vertical, 18)
                    } else {
                        responseGridPreview
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                    }
                    
                    Spacer()
                }
            }
            .padding(14)
        }
        .shadow(color: .black.opacity(0.22), radius: 20, x: 0, y: 10)
    }

    private var emptyResponsesPlaceholder: some View {
        VStack(spacing: 10) {
            Text("No responses yet")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            Text("Pick a preset above or add a response in the Responses tab.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var responseGridPreview: some View {
        let count = settingsButtonsList.count
        let cols = max(1, min(settingsViewModel.maxColumns, count))
        let spacing: CGFloat = 14

        // Design-time button size (use the largest stored button to keep proportions)
        let designW = CGFloat(settingsButtonsList.map { CGFloat($0.width) }.max() ?? 200)
        let designH = CGFloat(settingsButtonsList.map { CGFloat($0.height) }.max() ?? 200)

        let rows = Int(ceil(Double(count) / Double(cols)))

        // Natural (unscaled) grid size
        let requiredW = CGFloat(cols) * designW + CGFloat(max(cols - 1, 0)) * spacing
        let requiredH = CGFloat(rows) * designH + CGFloat(max(rows - 1, 0)) * spacing

        let gridItems = Array(repeating: GridItem(.fixed(designW), spacing: spacing), count: cols)

        return GeometryReader { geo in
            let availW = max(1, geo.size.width)
            let availH = max(1, geo.size.height)

            // Scale uniformly to fit, but never grow beyond 1.0
            let scale = min(availW / requiredW, availH / requiredH, 1.0)

            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(settingsButtonsList) { button in
                    previewResponseButton(button, baseSize: CGSize(width: designW, height: designH))
                }
            }
            .frame(width: requiredW, height: requiredH, alignment: .center)
            .scaleEffect(scale) // centered scaling
            .frame(width: availW, height: availH, alignment: .center) // centered in available space
        }
    }

    // MARK: - Inspector Pane

    private var inspectorPane: some View {
        VStack(spacing: 12) {
            Picker("", selection: $selectedTab) {
                ForEach(AdminTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)

            Divider().opacity(0.25)

            Group {
                if selectedTab == .responses {
                    responsesTab
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            switch selectedTab {
                            case .content:
                                contentTab
                            case .style:
                                styleTab
                            case .device:
                                deviceTab
                            case .responses:
                                EmptyView()
                            }
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 10)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().opacity(0.25)

            bottomActions
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white)
        )
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
    }

    // MARK: Tabs

    private var contentTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Question type presets")
                .font(.headline)
                .foregroundColor(Color("SWA-MidnightBlue"))

            presetsRow

            InspectorSection(title: "Caption") {
                TextField("Tap a button to respond.", text: $settingsViewModel.caption)
                    .textFieldStyle(.roundedBorder)
            }

            InspectorSection(title: "Question") {
                TextEditor(text: $settingsViewModel.prompt)
                    .frame(minHeight: 80, maxHeight: 140)
                    .padding(8)
                    .background(Color.black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }

            InspectorSection(title: "Layout") {
                HStack {
                    Text("Columns")
                        .foregroundColor(Color("SWA-MidnightBlue"))
                    Spacer()
                    Stepper(value: $settingsViewModel.maxColumns, in: 1...6) {
                        Text("\(settingsViewModel.maxColumns)")
                            .font(.headline)
                            .foregroundColor(Color("SWA-MidnightBlue"))
                            .frame(width: 28, alignment: .trailing)
                    }
                }
            }
        }
    }

    private var presetsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ResponsePreset.allCases) { preset in
                    PresetTile(preset: preset) {
                        requestPreset(preset)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var styleTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            InspectorSection(title: "Theme") {
                VStack(spacing: 12) {
                    colorRow(label: "Background", color: $settingsViewModel.background)
                    colorRow(label: "Caption Text", color: $settingsViewModel.captionColor)
                    colorRow(label: "Question Text", color: $settingsViewModel.promptColor)
                }
            }

            InspectorSection(title: "Quick backgrounds") {
                let swatches: [Color] = [
                    Color("SWA-BoldBlue"),
                    Color("SWA-DarkBlue"),
                    Color("SWA-DeepSilver"),
                    Color("SWA-MidnightBlue"),
                    Color("SWA-SummitSilver"),
                    Color("SWA-WarmRed"),
                    Color("SWA-SunriseYellow")
                ]

                HStack(spacing: 10) {
                    ForEach(swatches.indices, id: \.self) { i in
                        Button {
                            settingsViewModel.background = swatches[i]
                        } label: {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(swatches[i])
                                .frame(width: 34, height: 34)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.black.opacity(0.10), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button {
                        // A nice readable default pairing
                        settingsViewModel.captionColor = .white
                        settingsViewModel.promptColor = Color("SWA-SunriseYellow")
                    } label: {
                        Text("Reset text colors")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }

    private func colorRow(label: String, color: Binding<Color>) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Color("SWA-MidnightBlue"))
            Spacer()
            ColorPicker("", selection: color)
                .labelsHidden()
        }
    }

    private var responsesTab: some View {
        GeometryReader { geo in
            let sideBySide = geo.size.width >= 560

            Group {
                if sideBySide {
                    HStack(spacing: 12) {
                        responsesList
                            .frame(width: 250)

                        Divider().opacity(0.25)

                        ResponseEditorPane(
                            selected: $selectedResponse,
                            isAdding: $isAddingResponse,
                            nextIndex: settingsButtonsList.count + 1,
                            onSaved: { reindexButtonsAndSaveIfNeeded() },
                            onDeleted: { reindexButtonsAndSaveIfNeeded() }
                        )
                    }
                } else {
                    // compact: either list OR editor (editor goes “on top”)
                    if compactShowEditor {
                        VStack(spacing: 10) {
                            HStack {
                                Button {
                                    compactShowEditor = false
                                    // Optional: keep selection, or clear it:
                                    // selectedResponse = nil; isAddingResponse = false
                                } label: {
                                    Label("Responses", systemImage: "chevron.left")
                                        .font(.subheadline.weight(.semibold))
                                }

                                Spacer()
                            }

                            ResponseEditorPane(
                                selected: $selectedResponse,
                                isAdding: $isAddingResponse,
                                nextIndex: settingsButtonsList.count + 1,
                                onSaved: { reindexButtonsAndSaveIfNeeded() },
                                onDeleted: {
                                    reindexButtonsAndSaveIfNeeded()
                                    compactShowEditor = false
                                }
                            )
                        }
                    } else {
                        responsesList
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private var responsesList: some View {
        List {
            Section {
                ForEach(settingsButtonsList) { button in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: button.background ?? "000000") ?? .black)
                            .frame(width: 34, height: 34)

                        Text(button.title?.isEmpty == false ? (button.title ?? "") : (button.name ?? "Untitled"))
                            .foregroundColor(Color("SWA-MidnightBlue"))
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .listRowBackground((selectedResponse?.id == button.id) ? Color.black.opacity(0.06) : Color.clear)
                    .onTapGesture {
                        compactShowEditor = true
                        selectedResponse = button
                        isAddingResponse = false
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            dataContext.delete(button)
                            reindexButtonsAndSaveIfNeeded()
                            if selectedResponse?.id == button.id {
                                selectedResponse = nil
                                isAddingResponse = false
                                compactShowEditor = false
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveButtons)
            } header: {
                HStack {
                    Text("Responses")
                    Spacer()
                    Button {
                        compactShowEditor = true
                        selectedResponse = nil
                        isAddingResponse = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .font(.subheadline.weight(.semibold))
                    .textCase(nil)
                }
            } footer: {
                Text("Drag the handle to reorder. Order is saved automatically.")
            }
        }
        .listStyle(.insetGrouped)
        // Always show reorder handles
        .environment(\.editMode, .constant(.active))
    }

    private func reindexButtonsAndSaveIfNeeded() {
        let arr = settingsButtonsList.sorted { $0.index < $1.index }
        for (i, btn) in arr.enumerated() {
            btn.index = Int16(i + 1)
        }
        do { try dataContext.save() } catch { print("Save failed: \(error)") }
    }

    private var deviceTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Export metadata")
                .font(.headline)
                .foregroundColor(Color("SWA-MidnightBlue"))

            Text("These fields are not shown on the quiz screen, but they are included in the CSV export.")
                .font(.subheadline)
                .foregroundColor(.gray)

            InspectorSection(title: "Device name") {
                TextField("e.g. iPad-FrontCounter", text: $settingsViewModel.deviceName)
                    .textFieldStyle(.roundedBorder)
            }

            InspectorSection(title: "Quiz name") {
                TextField("e.g. Cleanliness Survey", text: $settingsViewModel.quizName)
                    .textFieldStyle(.roundedBorder)
            }

            InspectorSection(title: "Location") {
                TextField("e.g. Store #102 - Austin", text: $settingsViewModel.location)
                    .textFieldStyle(.roundedBorder)
            }

            InspectorSection(title: "Build info") {
                Button {
                    versionViewModel.isVersionDisplayed.toggle()
                } label: {
                    Text(versionViewModel.displayedString)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("SWA-MidnightBlue"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Bottom actions

    private var bottomActions: some View {
        HStack(spacing: 10) {
            if selectedTab != .responses {
                Button {
                    saveSettings(showConfirmation: true)
                } label: {
                    Label("Save", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("SWA-SunriseYellow"))
                .foregroundColor(Color("SWA-MidnightBlue"))
            }

            Button {
                exportConfirmAlertShowing = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("SWA-SunriseYellow"))
            .foregroundColor(Color("SWA-MidnightBlue"))

            Button {
                generateCsvDataAndShowSheet()
            } label: {
                Label("Data", systemImage: "doc.plaintext")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("SWA-SunriseYellow"))
            .foregroundColor(Color("SWA-MidnightBlue"))
        }
    }

    // MARK: Actions

    private func requestPreset(_ preset: ResponsePreset) {
        pendingPreset = preset
        if settingsButtonsList.isEmpty {
            applyPreset(preset)
            pendingPreset = nil
        } else {
            presetOverwriteAlertShowing = true
        }
    }

    private func saveSettings(showConfirmation: Bool) {
        settingsViewModel.updateSettings()
        do {
            try dataContext.save()
            if showConfirmation { settingsSavedAlertShowing = true }
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    private func exportData() {
        UploadDataManager.shared.createAndUploadCsv(dataContext: dataContext) { error in
            DispatchQueue.main.async {
                if let error = error {
                    dataExportResultMessage = "Data Export Failed!\n\(error.localizedDescription)"
                } else {
                    dataExportResultMessage = "Data Export Successful!"
                }
                dataExportResultShowing = true
            }
        }
    }

    private func generateCsvDataAndShowSheet() {
        DispatchQueue.main.async {
            _ = UploadDataManager.shared.generateCsvData(from: dataContext)
            showDataSheet = true
        }
    }

    private func deleteButtons(at offsets: IndexSet) {
        offsets.forEach { idx in
            dataContext.delete(settingsButtonsList[idx])
        }
        reindexButtonsAndSave()
    }

    private func moveButtons(from source: IndexSet, to destination: Int) {
        var arr = settingsButtonsList.map { $0 }
        arr.move(fromOffsets: source, toOffset: destination)
        for (i, btn) in arr.enumerated() {
            btn.index = Int16(i + 1)
        }
        do { try dataContext.save() } catch { print("Failed to save reorder: \(error)") }
    }

    private func reindexButtonsAndSave() {
        let arr = settingsButtonsList.map { $0 }.sorted { $0.index < $1.index }
        for (i, btn) in arr.enumerated() {
            btn.index = Int16(i + 1)
        }
        do { try dataContext.save() } catch { print("Failed to save: \(error)") }
    }

    private func applyPreset(_ preset: ResponsePreset) {
        // Delete existing
        settingsButtonsList.forEach { dataContext.delete($0) }

        // Add new preset buttons
        let defs = preset.buttonDefs()
        for (i, def) in defs.enumerated() {
            let b = SettingsButton(context: dataContext)
            b.id = UUID()
            b.name = def.name
            b.title = def.title
            b.index = Int16(i + 1)
            b.width = def.width
            b.height = def.height
            b.background = def.background.toHex() ?? "000000"
            b.titleColor = def.titleColor.toHex() ?? "FFFFFF"
            b.image = def.imagePNGData
        }

        // Sensible columns default
        settingsViewModel.maxColumns = min(6, preset.defaultColumns)
        settingsViewModel.updateSettings()

        do {
            try dataContext.save()
        } catch {
            print("Failed to apply preset: \(error)")
        }

        // Pop user into responses to fine-tune
        selectedTab = .responses
    }
}
