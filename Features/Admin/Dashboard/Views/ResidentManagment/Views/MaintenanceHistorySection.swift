//
//  MaintenanceHistorySection.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI



struct MaintenanceRequestRow: View {
    let request: MaintenanceRequest
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(request.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(dateFormatter.string(from: request.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Status badge
            StatusBadge(status: convertStatus(request.status).rawValue)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func convertStatus(_ status: String) -> ResidentStatus {
        switch status.lowercased() {
        case "active": return .active
        case "pending": return .pending
        default: return .inactive
        }
    }
}

// Make sure your MaintenanceRequest model looks like this:
struct MaintenanceRequest: Identifiable, Codable {
    let id: String
    let description: String
    let date: Date
    let status: String
    let residentId: String
    let unitNumber: String
    let title: String
    let urgency: String

}


struct MaintenanceHistorySection: View {
    let requests: [MaintenanceRequest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Maintenance History")
            
            ForEach(requests) { request in
                MaintenanceRequestRow(request: request)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

