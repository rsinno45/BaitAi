import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import DotLottie
import UIKit
import Lottie


class AuthViewModel: ObservableObject {
   @Published  var isAuthenticated = false
   @Published  var isAdmin = false
   @Published  var errorMessage: String?
   @Published  var isLoading = false

   // MARK: - Sign In
    func signIn(email: String, password: String) {
        print("Attempting to sign in with email: \(email)")  // Add this
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Sign in error: \(error.localizedDescription)")  // Add this
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully signed in
                if let user = result?.user {
                    print("Successfully signed in user: \(user.uid)")  // Add this
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
    @State private var showingAlert = false
    
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
                        
                        // Rest of your existing code...
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
