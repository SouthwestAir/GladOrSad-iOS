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
            return "https://h0j2q2mn1g.execute-api.us-east-1.amazonaws.com/dev/requests/putFile"
        case .prod:
            return "https://wtwiwzl9n0.execute-api.us-east-1.amazonaws.com/prod/requests/putFile"
        }
    }
    var apiKey: String {
        switch environment {
        case .dev, .qa:
            return "ANJpcZ8TVA3RnMM6yQF1N7BJhrHmMWbs1KSuIzhb"
        case .prod:
            return "mIrx94vUWG3GMmttv5vQ27MTDdRMlwdU2mQwhQnW"
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
