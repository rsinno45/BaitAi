//
//  PropertySelector.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct PropertySelector: View {
    @Binding var selectedPropertyId: String?
    let properties: [Property]
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All Properties Option
                PropertyChip(
                    name: "All Properties",
                    isSelected: selectedPropertyId == nil,
                    goldColor: goldColor
                ) {
                    selectedPropertyId = nil
                }
                
                // Individual Properties
                ForEach(properties) { property in
                    PropertyChip(
                        name: property.name,
                        isSelected: selectedPropertyId == property.id,
                        goldColor: goldColor
                    ) {
                        selectedPropertyId = property.id
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PropertyChip: View {
    let name: String
    let isSelected: Bool
    let goldColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? goldColor : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

