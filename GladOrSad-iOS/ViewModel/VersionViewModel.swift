//
//  VersionViewModel.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 6/25/24.
//

import SwiftUI

// Simulate Git information struct
struct GitInfo {
    static let gitBranch = "none"
    static let gitCommitHash = "undef"
    static let buildTime = "0"
}

// ViewModel to manage state
class VersionViewModel: ObservableObject {
    @Published var isVersionDisplayed: Bool = true
    
    var appVersion: String {
        if let release = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "Version \(release) (\(build))"
        }
        return "Unknown Version"
    }
    
    var versionString: String {
        #if STAGE_DEV
        return "\(appVersion) - DEV"
        #elseif STAGE_QA
        return "\(appVersion) - QA"
        #else
        return appVersion
        #endif
    }
    
    var gitInfoString: String {
        return "(\(GitInfo.gitCommitHash) \(GitInfo.gitBranch)) at \(GitInfo.buildTime)"
    }
    
    var displayedString: String {
        return isVersionDisplayed ? versionString : gitInfoString
    }
}
