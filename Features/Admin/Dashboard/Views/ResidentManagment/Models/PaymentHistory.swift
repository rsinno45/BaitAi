//
//  PaymentHistory.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct Payment: Identifiable, Codable {
    let id: String
    let residentId: String
    let amount: Double
    let date: Date
    let type: PaymentType
    let status: PaymentStatus
    let confirmationNumber: String?
    
    enum PaymentType: String, Codable {
        case rent, deposit, fee, other
    }
    
    enum PaymentStatus: String, Codable {
        case pending, completed, failed, refunded
    }
}

