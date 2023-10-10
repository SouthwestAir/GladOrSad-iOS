//
//  SettingsButtonViewModel.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/31/23.
//

import Foundation
import SwiftUI
import CoreData

class SettingsButtonViewModel: ObservableObject {
    @Published var id: UUID
    @Published var name: String
    @Published var title: String
    @Published var image: Data?
    @Published var index: Int
    @Published var width: Float
    @Published var height: Float
    
    private var hexBackground: String? {
        didSet {
            background = Color(hex: hexBackground ?? "000000") ?? Color("SWA-BoldBlue")
        }
    }
    @Published var background: Color
    private var hexTitleColor: String? {
        didSet {
            titleColor = Color(hex: hexTitleColor ?? "000000") ?? Color("SWA-White")
        }
    }
    @Published var titleColor: Color
    
    init(){
        id = UUID()
        name = ""
        title = ""
        image = nil
        index = 1
        width = 200.0
        height = 200.0
        
        background = Color("SWA-White")
        titleColor = Color("SWA-MidnightBlue")
    }
    
    init(settingsButton: SettingsButton) {
        id = settingsButton.id ?? UUID()
        name = settingsButton.name ?? ""
        title = settingsButton.title ?? ""
        image = settingsButton.image ?? nil
        index = Int(settingsButton.index)
        width = settingsButton.width
        height = settingsButton.height

        background = Color("SWA-White")
        titleColor = Color("SWA-MidnightBlue")

        hexBackground = settingsButton.background
        hexTitleColor = settingsButton.titleColor
    }
    
    func updateFromSettingsButton(settingsButton: SettingsButton) {
        id = settingsButton.id ?? UUID()
        name = settingsButton.name ?? ""
        title = settingsButton.title ?? ""
        image = settingsButton.image ?? nil
        index = Int(settingsButton.index)
        width = settingsButton.width
        height = settingsButton.height
        
        hexBackground = settingsButton.background
        hexTitleColor = settingsButton.titleColor
    }
    
    func updateExistingButton(_ existingButton: SettingsButton?) {
        guard let existingButton = existingButton else { return }

        existingButton.id = id
        existingButton.name = name
        existingButton.title = title
        existingButton.image = image
        existingButton.index = Int16(index)
        existingButton.width = width
        existingButton.height = height
        existingButton.background = background.toHex()
        existingButton.titleColor = titleColor.toHex()
    }
    
    func newSettingsButton(viewContext: NSManagedObjectContext) -> SettingsButton {
        let newButton = SettingsButton(context: viewContext)
        newButton.id = id
        newButton.name = name
        newButton.title = title
        newButton.image = image
        newButton.index = Int16(index)
        newButton.width = width
        newButton.height = height
        newButton.background = background.toHex()
        newButton.titleColor = titleColor.toHex()
        
        print("Button \(newButton)")
        return newButton
    }
    
    func reset() {
        id = UUID()
        name = ""
        title = ""
        image = nil
        index = 1
        width = 200.0
        height = 200.0
        
        background = Color("SWA-White")
        titleColor = Color("SWA-MidnightBlue")
    }
}
