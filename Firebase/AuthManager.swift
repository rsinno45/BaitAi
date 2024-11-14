//
//  AuthManager.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

import SwiftUI

class AuthManager {
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await auth.signIn(withEmail: email, password: password)
        let uid = result.user.uid
        
        // Get user data from Firestore
        let userDoc = try await db.collection("users").document(uid).getDocument()
        guard let userData = userDoc.data(),
              let roleString = userData["role"] as? String,
              let role = UserRole(rawValue: roleString) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        return AppUser(
            id: uid,
            email: email,
            role: role,
            firstName: userData["firstName"] as? String,
            lastName: userData["lastName"] as? String,
            propertyId: userData["propertyId"] as? String
        )
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}
