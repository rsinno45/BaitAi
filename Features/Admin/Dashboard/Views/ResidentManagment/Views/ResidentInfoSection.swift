//
//  ResidentInfoSection.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentInfoSection: View {
    let resident: Resident
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(spacing: 15) {
            // Profile Header
            Circle()
                .fill(goldColor)
                .frame(width: 100, height: 100)
                .overlay(
                    Text(resident.initials)
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .medium))
                )
            
            Text("\(resident.firstName) \(resident.lastName)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Contact Info
            InfoRow(title: "envelope.fill", value: resident.email)
            InfoRow(title: "phone.fill", value: resident.phone)
            InfoRow(title: "house.fill", value: "Unit \(resident.unitNumber)")
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct InfoRow: View {
    let title: String
    let value: Any?
    
    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .foregroundColor(.gray)
            Text("\(String(describing: value))")
                .foregroundColor(.white)
            Spacer()
        }
    }
}

