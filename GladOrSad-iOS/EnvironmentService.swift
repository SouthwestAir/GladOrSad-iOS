//
//  EnvironmentService.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 3/13/23.
//

import Foundation

enum BuildConfiguration: String {
    case debugDev = "Debug Dev"
    case releaseDev = "Release Dev"
    
    case debugQa = "Debug Qa"
    case releaseQa = "Release Qa"
    
    case debugProd = "Debug Prod"
    case releaseProd = "Release Prod"
}

enum EnvironmentType: String {
    case dev = "dev"
    case qa = "qa"
    case prod = "prod"
}

class EnvironmentService: NSObject {
    static let shared = EnvironmentService()
    var buildConfiguration: BuildConfiguration
    var environment: EnvironmentType {
        switch buildConfiguration {
        case .debugDev, .releaseDev:
            return .dev
        case .debugQa, .releaseQa:
            return .qa
        case .debugProd, .releaseProd:
            return .prod
        }
    }
    var presignedUrl: String {
        switch environment {
        case .dev, .qa:
            return "REPLACE-WITH-URL/putFile"
        case .prod:
            return "REPLACE-WITH-URL/putFile"
        }
    }
    var apiKey: String {
        switch environment {
        case .dev, .qa:
            return "REPLACE-WITH-API-KEY-TO-AWS"
        case .prod:
            return "REPLACE-WITH-API-KEY-TO-AWS"
        }
    }
    
    private override init() {
        let envConfiguration = Bundle.main.object(forInfoDictionaryKey: "env") as! String
        guard let env = BuildConfiguration(rawValue: envConfiguration) else {
            buildConfiguration = .debugDev
            return
        }
        buildConfiguration = env
    }
    
}
