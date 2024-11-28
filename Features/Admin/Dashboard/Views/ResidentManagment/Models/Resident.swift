

//
//  Resident.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI
import Firebase

enum ResidentStatus: String, Codable, CaseIterable {
    case active = "active"
    case pending = "pending"
    case inactive = "inactive"
    case all = "all"
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
    var organizationId: String
    
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
        case organizationId
    }
    
    var initials: String {
            let firstInitial = firstName.prefix(1)
            let lastInitial = lastName.prefix(1)
            return "\(firstInitial)\(lastInitial)"
        }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        unitNumber = try container.decode(String.self, forKey: .unitNumber)
        propertyId = try container.decode(String.self, forKey: .propertyId)
        status = try container.decode(ResidentStatus.self, forKey: .status)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        organizationId = try container.decode(String.self, forKey: .organizationId)
    }
    
    init(id: String = UUID().uuidString,
         firstName: String,
         lastName: String,
         email: String,
         phone: String,
         unitNumber: String,
         propertyId: String,
         status: ResidentStatus,
         createdAt: Date = Date(),
         organizationId: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.unitNumber = unitNumber
        self.propertyId = propertyId
        self.status = status
        self.createdAt = createdAt
        self.organizationId = organizationId
    }
    
    // Keep your existing document initializer
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.unitNumber = data["unitNumber"] as? String ?? ""
        self.propertyId = data["propertyId"] as? String ?? ""
        self.organizationId = data["organizationId"] as? String ?? ""
        self.status = ResidentStatus(rawValue: data["status"] as? String ?? "") ?? .pending
        
        // Handle date conversion from Timestamp
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}
