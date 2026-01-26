//
//  AdminTab.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import Foundation

enum AdminTab: String, CaseIterable, Identifiable {
    case content = "Content"
    case style = "Style"
    case responses = "Responses"
    case device = "Device"
    var id: String { rawValue }
}
