//
//  ResidentDocument.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentDocument: Codable, Identifiable {
    let id: String
    let name: String
    let uploadDate: Date
    let type: String
    let url: String
}
