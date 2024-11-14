//
//  LeaseDetailsSection.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//
import SwiftUI

struct LeaseDetailsSection: View {
    let lease: LeaseDetails
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Lease Details")
            
            VStack(spacing: 10) {
              //  InfoRow(title: "Start Date", value: formatDate(date: lease.startDate))
               // InfoRow(title: "End Date", value: formatDate(date: lease.endDate))
                //InfoRow(title: "Monthly Rent", value: lease.monthlyRent)
                //InfoRow(title: "Security Deposit", value: lease.securityDeposit)
            }

        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct SectionHeader: View {
    let title: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(goldColor)
        }
    }
}

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: date)
}

