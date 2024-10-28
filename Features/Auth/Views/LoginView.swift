import SwiftUI

struct LoginView: View {
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
                        .foregroundColor(isAdmin ? .black : .black) // Keep text black for readability
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(isAdmin ? .black : .black) // Keep text black for readability
                }
                .padding(.horizontal, 32)
                
                // Login Button
                Button(action: {
                    isAuthenticated = true  // Just this one line, like in TestView
                    
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

                // Forgot Password Link
                Button(action: {
                    // Add forgot password logic
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(goldColor)
                        .font(.footnote)
                }
                
                Spacer()
                
                // Sign Up Link
                HStack {
                         Text("Don't have an account?")
                             .foregroundColor(isAdmin ? .gray : .gray)
                    Button(action: {
                                withAnimation {
                                    isShowingLogin = false
                                }
                            }) {
                                Text("Sign Up")
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

