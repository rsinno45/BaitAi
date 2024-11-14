

//
//  Resident.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI
import Firebase

enum ResidentStatus: String, Codable, CaseIterable {
    case active = "Active"
    case inactive = "Inactive"
    case pending = "Pending"
    case all = "All"
}

struct Resident: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var unitNumber: String
    var propertyId: String
    var status: ResidentStatus
    var createdAt: Date
    var adminId: String

    // Computed properties (not part of Codable)
    var initials: String {
        let firstInitial = firstName.prefix(1)
        let lastInitial = lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)"
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    // Explicit coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case phone
        case unitNumber
        case propertyId
        case status
        case createdAt
        case adminId
    }

    // Custom initializer
    init(id: String = UUID().uuidString,
         firstName: String,
         lastName: String,
         email: String,
         phone: String,
         unitNumber: String,
         propertyId: String,
         status: ResidentStatus,
         adminId: String,
         createdAt: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.unitNumber = unitNumber
        self.propertyId = propertyId
        self.status = status
        self.createdAt = createdAt
        self.adminId = adminId
    }
    
    // Add Firestore document initializer
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        // Use document ID as the resident ID
        self.id = document.documentID
        
        // Extract other fields with proper type casting
        guard let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let email = data["email"] as? String,
              let phone = data["phone"] as? String,
              let unitNumber = data["unitNumber"] as? String,
              let propertyId = data["propertyId"] as? String,
              let statusRawValue = data["status"] as? String,
              let adminId = data["adminId"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.unitNumber = unitNumber
        self.propertyId = propertyId
        self.status = ResidentStatus(rawValue: statusRawValue) ?? .pending
        self.createdAt = createdAt
        self.adminId = adminId
    }
}
