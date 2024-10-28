import SwiftUI

struct AdminDashboardView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @Binding var isAuthenticated: Bool
    @State private var showingSignOutAlert = false
    @State private var isShowingPropertiesView = false
    
    var body: some View {
        ZStack {
            // Black background for admin
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome Back,")
                            .font(.title2)
                        Text("Admin")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Profile Image
                    Circle()
                        .fill(goldColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("A")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        )
                }
                .padding()
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Admin Quick Actions
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                            QuickActionButton(icon: "person.2.fill", title: "Residents", subtitle: "Manage residents") {}
                            QuickActionButton(icon: "wrench.fill", title: "Maintenance", subtitle: "12 Active requests") {}
                            QuickActionButton(icon: "building.2.fill", title: "Amenities", subtitle: "Manage bookings") {}
                            QuickActionButton(icon: "chart.line.uptrend.xyaxis", title: "Analytics", subtitle: "View reports") {}
                                QuickActionButton(
                                                            icon: "building.2.fill",
                                                            title: "Properties",
                                                            subtitle: "Manage properties"
                                                        ) {
                                                            isShowingPropertiesView = true
                                                        }
                                                    }

                    
                        }
                        .padding(.horizontal)
                        if isShowingPropertiesView {
                            PropertiesView(isShowingPropertiesView: $isShowingPropertiesView)
                                .transition(.move(edge: .trailing))
                        }

                        // Recent Activity Section
                        // ... (similar to resident dashboard but with admin-specific activities)

                        // Add more admin-specific sections as needed
                    }
                    .padding(.vertical)
                }
            }
            
            // Sign Out Button at the bottom
            VStack {
                Spacer()
                Button(action: {
                    showingSignOutAlert = true
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
                .alert("Sign Out", isPresented: $showingSignOutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        withAnimation {
                            isAuthenticated = false
                        }
                    }
                } message: {
                    Text("Are you sure you want to sign out?")
                }
            }
        }
    }




