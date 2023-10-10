//
//  SettingsTextField.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 8/8/23.
//

import SwiftUI

struct SettingsTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var label: String
    var prompt: String
    
    var body: some View {
        HStack {
            Text(label).frame(minWidth: 150, alignment: .trailing).padding(.trailing, 10.0)
            TextField(prompt, text: $text)
                .disableAutocorrection(true)
                .foregroundColor(Color("SWA-MidnightBlue"))
                .border(Color("SWA-SunriseYellow"), width: isFocused ? 4 : 0)
                .focused($isFocused)
                .onChange(of: isFocused) { newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // select all text
                            text = text
                        }
                    }
                }
        }
        .textFieldStyle(.roundedBorder)
    }
}


struct SettingsTextField_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTextField(text: .constant(""), label: "Field Label", prompt: "The details for the field")
    }
}
