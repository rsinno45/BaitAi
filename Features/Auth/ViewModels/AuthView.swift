import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()  // Add this
    @Binding var isAuthenticated: Bool
    @State private var showingLogin = true
    @Binding var isAdmin: Bool
    
    var body: some View {
        ZStack {
            LoginView(viewModel: viewModel,           // Pass viewModel here
                     isShowingLogin: $showingLogin,
                     isAuthenticated: $isAuthenticated,
                     isAdmin: $isAdmin)
                .zIndex(0)
            
            if !showingLogin {
                SignUpView(viewModel: viewModel,      // Pass viewModel here
                          isShowingLogin: $showingLogin,
                          isAuthenticated: $isAuthenticated,
                          isAdmin: $isAdmin)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingLogin)
    }
}

