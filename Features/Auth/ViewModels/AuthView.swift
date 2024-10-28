import SwiftUI

struct AuthView: View {
    @Binding var isAuthenticated: Bool      // Receives binding
    @State private var showingLogin = true
    @Binding var isAdmin: Bool

    
    
    var body: some View {
            ZStack {
                LoginView(isShowingLogin: $showingLogin,
                         isAuthenticated: $isAuthenticated,
                         isAdmin: $isAdmin)  // Pass isAdmin
                    .zIndex(0)
                
                if !showingLogin {
                    SignUpView(isShowingLogin: $showingLogin,
                              isAuthenticated: $isAuthenticated)  // Pass isAdmin
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingLogin)
        }
}

// Add this Preview Provider
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(isAuthenticated: .constant(false), isAdmin: .constant(false))
    }
}

// Or if you're using the newer preview macro syntax
#Preview {
    AuthView(isAuthenticated: .constant(false), isAdmin: .constant(false))
}
