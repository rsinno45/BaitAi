//
//  ResidentSearchBar.swift .swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentSearchBar: View {
    @Binding var text: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(goldColor)
            
            TextField("Search residents...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
