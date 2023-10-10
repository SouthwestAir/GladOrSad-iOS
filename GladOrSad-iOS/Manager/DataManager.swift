//
//  DataManager.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/5/23.
//

import Foundation
import CoreData
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container:NSPersistentContainer
    
    static var preview: DataManager = {
        let model = DataManager(preview: true)
        return model
    }()

    init(preview: Bool = false) {
        container = NSPersistentContainer(name: "GladOrSad")
        if preview {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load core data: \(error)")
            }
        }
        loadBasicSettings()
    }
    
    private func loadBasicSettings() {
        let viewContext = container.viewContext
        let fetchRequest: NSFetchRequest<Settings> = NSFetchRequest(entityName: "Settings")
        var count = 0
        do{
            count = try viewContext.count(for: fetchRequest)
            print("\(count) Settings found")
        } catch {
            print("Counting Settings failed \(error)")
        }
        if count < 1 {
            let settings = Settings(context: viewContext)
            settings.id = UUID()
            settings.caption = "Edit Settings to set Caption"
            settings.prompt = "Edit Settings to set Prompt"
            settings.deviceName = ""
            settings.quizName = ""
            settings.location = ""
            settings.background = Color("SWA-BoldBlue").toHex()
            settings.captionColor = Color("SWA-White").toHex()
            settings.promptColor = Color("SWA-White").toHex()
            
            do {
                try viewContext.save()
                print("Default Settings created")
            } catch {
               print("Creating default Settings failed \(error)")
            }
        }
    }
}
