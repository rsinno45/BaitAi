import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var isShowingLogin: Bool
    @Binding var isAuthenticated: Bool
    @Binding var isAdmin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var unitNumber = ""
    
    // Define colors
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    
    // Validation
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        (!unitNumber.isEmpty || isAdmin) && // Unit number only required for residents
        password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Background color that changes with toggle
            (isAdmin ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Your existing UI code until the input fields...
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        HStack(spacing: 15) {
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        if !isAdmin {  // Only show unit number for residents
                            TextField("Unit Number", text: $unitNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: goldColor))
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        if isFormValid {
                            viewModel.signUp(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName,
                                unitNumber: unitNumber,
                                isAdmin: isAdmin
                            )
                        }
                    }) {
                        HStack {
                            Text("Create Account")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(isAdmin ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFormValid ? goldColor : goldColor.opacity(0.5))
                                .shadow(color: goldColor.opacity(0.5), radius: 5, x: 0, y: 3)
                        )
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 32)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                    
                    // Your existing login link code...
                }
                .padding(.top, 60)
            }
        }
    }
}
