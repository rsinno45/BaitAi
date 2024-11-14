//
//  LeaseDetails.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI
import FirebaseCore

enum LeaseStatusNew: String, Codable {
    case active
    case pending
    case expired
    case terminated
    case renewed
}


struct LeaseDetails: Codable {
    let moveInDate: Date
    let leaseEndDate: Date?
    let rentAmount: Double
    let rentStatus: String
    
    enum CodingKeys: String, CodingKey {
        case moveInDate
        case leaseEndDate
        case rentAmount
        case rentStatus
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        moveInDate = try container.decode(Date.self, forKey: .moveInDate)
        leaseEndDate = try container.decodeIfPresent(Date.self, forKey: .leaseEndDate)
        rentAmount = try container.decode(Double.self, forKey: .rentAmount)
        rentStatus = try container.decode(String.self, forKey: .rentStatus)
    }
    
    init(moveInDate: Date, leaseEndDate: Date?, rentAmount: Double, rentStatus: String) {
        self.moveInDate = moveInDate
        self.leaseEndDate = leaseEndDate
        self.rentAmount = rentAmount
        self.rentStatus = rentStatus
    }
}
