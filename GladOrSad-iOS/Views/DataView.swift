//
//  DataView.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 6/25/24.
//

import SwiftUI

struct DataView: View {
    var body: some View {
        if let data = UploadDataManager.shared.csvData {
            ScrollView {
                VStack(alignment: .leading) {
                    let rows = data.split(separator: "\n").map { $0.split(separator: ",").map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) } }
                    
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        let row = rows[rowIndex]
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: row.count), alignment: .leading) {
                            ForEach(row.indices, id: \.self) { colIndex in
                                let column = row[colIndex]
                                Text(column)
                                    .padding(.bottom, 2)
                                    .padding(.trailing, 4)
                                    .bold(rowIndex == 0)
                                    .foregroundColor(rowIndex == 0 ? .white : .black)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.cyan)
        } else {
            Text("No data available.")
                .padding()
                .background(Color.cyan)
        }
    }
}
