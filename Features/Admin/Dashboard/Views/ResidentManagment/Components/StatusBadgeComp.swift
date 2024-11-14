//
//  StatusBadgeComp.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct StatusBadgeComp: View {
    let status: ResidentStatus
    
    var statusColor: Color {
        switch status {
        case .active: return .green
        case .inactive: return .red
        case .pending: return .orange
        case .all: return .gray
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}
