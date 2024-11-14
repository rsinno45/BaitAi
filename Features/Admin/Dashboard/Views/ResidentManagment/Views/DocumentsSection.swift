//
//  DocumentsSection.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct DocumentRow: View {
    let document: ResidentDocument
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(goldColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .foregroundColor(.white)
                
                Text(document.uploadDate.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                // Action to view/download document
            }) {
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(goldColor)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}


struct DocumentsSection: View {
    let documents: [ResidentDocument]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Documents")
            
            ForEach(documents) { document in
                DocumentRow(document: document)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

