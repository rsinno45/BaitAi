//
//  AuthViewModel.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

// AuthViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

 class AuthViewModel: ObservableObject {
    @Published  var isAuthenticated = false
    @Published  var isAdmin = false
    @Published  var errorMessage: String?
    @Published  var isLoading = false
    


    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully signed in
                if let user = result?.user {
                    // Check if user is admin (we'll implement this next)
                    self.checkUserRole(userId: user.uid)
                }
            }
        }
    }
    
    // MARK: - Check User Role
    private func checkUserRole(userId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    // Check if user is admin
                    self.isAdmin = document.data()?["role"] as? String == "admin"
                    self.isAuthenticated = true
                } else {
                    self.errorMessage = "User data not found"
                }
            }
        }
    }
}
