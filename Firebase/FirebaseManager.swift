//
//  FirebaseManager.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    private init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
    }
}

enum UserRole: String {
    case admin
    case resident
}

struct AppUser {
    let id: String
    let email: String
    let role: UserRole
    var firstName: String?
    var lastName: String?
    var propertyId: String? // for residents
}


