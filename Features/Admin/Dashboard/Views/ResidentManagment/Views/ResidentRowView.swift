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
            Circle()
                .fill(goldColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(resident.initials)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(resident.firstName) \(resident.lastName)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Unit \(resident.unitNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            StatusBadgeComp(status: resident.status)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}
