import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import DotLottie
import UIKit
import Lottie

// Add this struct to store credentials
struct UserCredentials {
    static var shared = UserCredentials()
    var email: String?
    var password: String?
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isAdmin = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var organizationId: String?
    
    // MARK: - Sign In
    func signIn(email: String, password: String) {
        print("Attempting to sign in with email: \(email)")
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Sign in error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully signed in
                if let user = result?.user {
                    print("Successfully signed in user: \(user.uid)")
                    // Store credentials when sign in is successful
                    UserCredentials.shared.email = email
                    UserCredentials.shared.password = password
                    self.checkUserRole(userId: user.uid)
                }
            }
        }
    }
    
    // MARK: - Check User Role
    private func checkUserRole(userId: String) {
        let db = Firestore.firestore()
        
        // First get all organizations
        db.collection("organization").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            // Check each organization for this admin
            for organization in snapshot?.documents ?? [] {
                let orgId = organization.documentID
                
                // Check the admins subcollection for this user
                db.collection("organization")
                    .document(orgId)
                    .collection("admins")
                    .document(userId)
                    .getDocument { (adminDoc, error) in
                        DispatchQueue.main.async {
                            if let adminDoc = adminDoc, adminDoc.exists {
                                // Found the admin
                                self.isAdmin = true
                                self.isAuthenticated = true
                                self.organizationId = orgId
                                
                                // Log success
                                print("Found admin in organization: \(orgId)")
                                
                                // You can also get admin data if needed
                                if let adminData = adminDoc.data() {
                                    print("Admin data:", adminData)
                                }
                            } else if error != nil {
                                self.errorMessage = error?.localizedDescription
                            }
                        }
                    }
            }
        }
    }
    
    // Add to your AuthViewModel class:
    func signUp(email: String, password: String, firstName: String, lastName: String, unitNumber: String, isAdmin: Bool) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully created auth user, now create Firestore document
                if let user = result?.user {
                    self.createUserDocument(
                        user: user,
                        firstName: firstName,
                        lastName: lastName,
                        unitNumber: unitNumber,
                        isAdmin: isAdmin
                    )
                }
            }
        }
    }
    
    private func createUserDocument(user: User, firstName: String, lastName: String, unitNumber: String, isAdmin: Bool) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "unitNumber": unitNumber,
            "role": isAdmin ? "admin" : "resident",
            "createdAt": Timestamp(date: Date()),
            "phoneNumber": "",  // Add these fields
            "moveInDate": "Sept 1, 2023",  // Add with default values
            "leaseEndDate": "Aug 2025",    // Add with default values
            "rentStatus": "Paid"           // Add with default values
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error creating user profile: \(error.localizedDescription)"
                } else {
                    self.isAdmin = isAdmin
                    self.isAuthenticated = true
                }
            }
        }
    }
}

struct LoginView: View {
    @StateObject var viewModel = AuthViewModel()
    @Binding var isShowingLogin: Bool
    @Binding var isAuthenticated: Bool
    @Binding var isAdmin: Bool
    @State private var email = ""
    @State private var password = ""
    
    // Define colors
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        ZStack {
            // Background color that changes with toggle
            (isAdmin ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Center everything using GeometryReader
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo/Title Area
                        Text("Bait.ai")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isAdmin ? .white : .black)
                            .padding(.bottom, 30)
                        
                        // User Type Toggle
                        HStack {
                            Toggle("", isOn: $isAdmin)
                                .tint(goldColor)
                            Text("Admin")
                                .foregroundColor(isAdmin ? .white : .gray)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 10)
                        
                        // Input Fields
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocorrectionDisabled()
                                .foregroundColor(.black)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 32)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: goldColor))
                        }
                        
                        // Login Button
                        Button(action: {
                            viewModel.signIn(email: email, password: password)
                        }) {
                            Text("Log In")
                                .font(.headline)
                                .foregroundColor(isAdmin ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(goldColor)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 32)
                        .onChange(of: viewModel.isAuthenticated) { oldValue, newValue in
                            isAuthenticated = newValue
                        }
                        .onChange(of: viewModel.isAdmin) { oldValue, newValue in
                            isAdmin = newValue
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                        }
                        
                        // Forgot Password Link
                        Button(action: {
                            // Add forgot password logic
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(goldColor)
                                .font(.footnote)
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .frame(maxWidth: 400)
            .frame(maxWidth: .infinity)
        }
    }
}
