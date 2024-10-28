import SwiftUI

struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Circle()
                            .fill(goldColor)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("JD")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40, weight: .medium))
                            )
                        
                        Text("John Doe")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Unit 301")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                    
                    // Quick Info Cards
                    HStack(spacing: 15) {
                        InfoCard(title: "Lease Ends", value: "Aug 2025")
                        InfoCard(title: "Rent Status", value: "Paid")
                    }
                    .padding(.horizontal)
                    
                    // Profile Sections
                    VStack(spacing: 5) {
                        ProfileSection(title: "Personal Information", icon: "person.fill") {
                            ProfileRow(title: "Email", value: "john.doe@email.com")
                            ProfileRow(title: "Phone", value: "(555) 123-4567")
                            ProfileRow(title: "Move-in Date", value: "Sept 1, 2023")
                        }
                        
                        ProfileSection(title: "Documents", icon: "doc.fill") {
                            ProfileRow(title: "Lease Agreement", value: "View →")
                            ProfileRow(title: "Renter's Insurance", value: "View →")
                            ProfileRow(title: "Building Rules", value: "View →")
                        }
                        
                        ProfileSection(title: "Preferences", icon: "gear") {
                            ProfileRow(title: "Notifications", value: "On")
                            ProfileRow(title: "Auto-pay", value: "Enabled")
                            ProfileRow(title: "Language", value: "English")
                        }
                        
                        ProfileSection(title: "Support", icon: "questionmark.circle") {
                            ProfileRow(title: "Help Center", value: "")
                            ProfileRow(title: "Contact Support", value: "")
                            ProfileRow(title: "FAQs", value: "")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign Out Button
                    Button(action: {
                        isAuthenticated = false  // Just this one line, like in TestView
                    }) {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding()

                }
            }
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(goldColor)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.vertical, 5)
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}


