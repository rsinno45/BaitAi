import SwiftUI



struct MainTabView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @Binding var isAuthenticated: Bool
   
    
    var body: some View {
        TabView {
            ResidentDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Access View")
                .tabItem {
                    Image(systemName: "key.fill")
                    Text("Access")
                }
            
            MessageView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
            
            ProfileView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(goldColor)
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var isAuthenticated = true
        
        
        var body: some View {
            MainTabView(
                isAuthenticated: $isAuthenticated
            )
        }
    }
    
    return PreviewContainer()
}

