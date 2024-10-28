import SwiftUI

struct SignUpView: View {
    @Binding var isShowingLogin: Bool
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var unitNumber = ""
    @State private var showingAlert = false
    @State private var isAdmin = false
    
    // Define colors
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    
    var body: some View {
        ZStack {
            // Background color that changes with toggle
            (isAdmin ? Color.black : Color.white)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Logo/Title Area
                    Text("Join Bait.ai")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(isAdmin ? .white : .black)
                    
                    // User Type Toggle
                    HStack {
                        Toggle("", isOn: $isAdmin)
                            .tint(goldColor)
                        Text("Admin")
                            .foregroundColor(isAdmin ? .white : .gray)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 32)
                    
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
                         
                        
                        TextField("Unit Number", text: $unitNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    
                    // Sign Up Button
                    Button(action: {
                        showingAlert = true
                        isAuthenticated = true
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
                                .fill(goldColor)
                                .shadow(color: goldColor.opacity(0.5), radius: 5, x: 0, y: 3)
                        )
                    }
                    .padding(.horizontal, 32)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text(isAdmin ? "Admin Sign Up" : "Tenant Sign Up"),
                            message: Text("Add your registration logic here"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    
                    // Login Link
                    HStack {
                                Text("Already have an account?")
                                    .foregroundColor(isAdmin ? .gray : .gray)
                        Button(action: {
                                    withAnimation {
                                        isShowingLogin = true
                                    }
                                }) {
                                    Text("Log In")
                                        .foregroundColor(goldColor)
                                        .fontWeight(.semibold)
                                }
                            }
                    .font(.footnote)
                    .padding(.bottom, 20)
                }
                .padding(.top, 60)
            }
        }
    }
}

