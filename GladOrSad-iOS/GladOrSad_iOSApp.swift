//
//  GladOrSad_iOSApp.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 6/12/23.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}


@main
struct GladOrSad_iOSApp: App {
    @StateObject private var dataManager = DataManager()
    
    @State private var path = NavigationPath()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path, root: {
                RatingView()
                    .environmentObject(dataManager)
                    .environment(\.managedObjectContext, dataManager.container.viewContext)
            })
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .statusBarHidden(true)
            .tint(Color("SWA-White"))
            .onAppear{
                printSqlLiteLocation()
            }
        }
    }
    
    func printSqlLiteLocation(){
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
    }
    
}
