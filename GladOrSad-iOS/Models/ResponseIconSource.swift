//
//  ResponseIconSource.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 1/20/26.
//

import Foundation

enum ResponseIconSource: String, CaseIterable, Identifiable {
    case none = "None"
    case emoji = "Emoji"
    case sfSymbol = "SF Symbol"
    var id: String { rawValue }
}
