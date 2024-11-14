//
//  ResidentDocument.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentDocument: Identifiable, Codable {
    let id: String
    let residentId: String
    let name: String
    let type: DocumentType
    let url: String
    let uploadDate: Date
    let expirationDate: Date?
    
    enum DocumentType: String, Codable {
        case lease, identification, insurance, other
    }
}


