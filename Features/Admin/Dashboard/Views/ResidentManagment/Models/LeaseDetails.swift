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


struct LeaseDetails: Codable, Identifiable {
    let id: String
    let startDate: Date
    let endDate: Date
    let monthlyRent: Double
    let securityDeposit: Double
}
