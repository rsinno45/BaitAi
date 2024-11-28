//
//  ResidentRowView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentRowView: View {
    let resident: Resident
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack(spacing: 15) {
            // Resident Status Indicator
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(resident.firstName) \(resident.lastName)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Unit \(resident.unitNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(goldColor)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var statusColor: Color {
        switch resident.status {
        case .active: return .green
        case .pending: return .orange
        case .inactive: return .red
        default: return .gray
        }
    }
}
