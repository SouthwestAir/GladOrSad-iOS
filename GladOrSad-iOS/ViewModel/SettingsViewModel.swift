//
//  SettingsViewModel.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/30/23.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    let defaultCaption = "Edit Settings to set Caption"
    let defaultPrompt = "Edit Settings to set Prompt"
    
    @Published var id: UUID
    @Published var deviceName: String
    @Published var quizName: String
    @Published var location: String
    @Published var caption: String
    @Published var prompt: String
    @Published var maxColumns: Int
    
    private var hexCaptionColor: String? {
        didSet {
            captionColor = Color(hex: hexCaptionColor ?? "000000") ?? Color("SWA-White")
        }
    }
    @Published var captionColor: Color
    private var hexPromptColor: String? {
        didSet {
            promptColor = Color(hex: hexPromptColor ?? "000000") ?? Color("SWA-SunriseYellow")
        }
    }
    @Published var promptColor: Color
    private var hexBackground: String? {
        didSet {
            background = Color(hex: hexBackground ?? "000000") ?? Color("SWA-BoldBlue")
        }
    }
    @Published var background: Color
    
    private var settings: Settings?
    
    init(settings: Settings){
        id = settings.id ?? UUID()
        deviceName = settings.deviceName ?? ""
        quizName = settings.quizName ?? ""
        location = settings.location ?? ""
        caption = settings.caption ?? defaultCaption
        prompt = settings.prompt ?? defaultPrompt
        maxColumns = Int(settings.maxColumns)

        captionColor = Color("SWA-White")
        promptColor = Color("SWA-SunriseYellow")
        background = Color("SWA-BoldBlue")

        hexCaptionColor = settings.captionColor
        hexPromptColor = settings.promptColor
        hexBackground = settings.background
    }
    
    init(){
        id = UUID()
        deviceName = ""
        quizName = ""
        location = ""
        caption = defaultCaption
        prompt = defaultPrompt
        maxColumns = 5

        captionColor = Color("SWA-White")
        promptColor = Color("SWA-SunriseYellow")
        background = Color("SWA-BoldBlue")
        
        print("^^^^^ SettingsViewModel()")
    }
    
    func updateFromSettings(settings: Settings) {
        self.settings = settings
        
        id = settings.id ?? UUID()
        deviceName = settings.deviceName ?? ""
        quizName = settings.quizName ?? ""
        location = settings.location ?? ""
        caption = settings.caption ?? defaultCaption
        prompt = settings.prompt ?? defaultPrompt
        maxColumns = Int(settings.maxColumns)

        hexCaptionColor = settings.captionColor
        hexPromptColor = settings.promptColor
        hexBackground = settings.background
    }
    
    func updateSettings() {
        if let settings = settings {
            settings.deviceName = deviceName
            settings.quizName = quizName
            settings.location = location
            settings.caption = caption
            settings.prompt = prompt
            settings.maxColumns = Int16(maxColumns)

            settings.captionColor = captionColor.toHex()
            settings.promptColor = promptColor.toHex()
            settings.background = background.toHex()
        }
    }
}
