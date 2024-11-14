//
//  MaintenanceRequest.swift
//  BaitAi
//
//  Created by Rakan Sinno on 11/12/24.
import SwiftUI

struct MaintenanceRequestAdmin: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let residentId: String
    let propertyId: String
    let status: String // Changed from enum to String
    let urgency: String // Changed from enum to String
    let createdAt: Date
    var updatedAt: Date
    let unitNumber: String // Add this
    let companyId: String

    enum RequestStatus: String, Codable {
        case active = "active"
        case completed = "completed"
    }
    
    enum UrgencyLevel: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
    }
}




// Message Model
struct MaintenanceMessage: Identifiable, Codable {
    let id: String
    let requestId: String
    let senderId: String
    let senderRole: UserRole
    let content: String
    let timestamp: Date
    var isRead: Bool
    
    enum UserRole: String, Codable {
        case admin = "admin"
        case resident = "resident"
    }
}
