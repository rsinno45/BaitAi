import SwiftUI

struct AdminDashboardView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @Binding var isAuthenticated: Bool
    @State private var showingSignOutAlert = false
    @State private var isShowingPropertiesView = false
    @State private var isShowingResidentsView = false
    @State private var isShowingMaintenanceView = false
    @State private var isShowingAmenitiesView = false
    @State private var isShowingAnalyticsView = false
    @StateObject private var maintenanceViewModel = MaintenanceRequestViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isShowingPropertiesView {
                            PropertiesView(isShowingPropertiesView: $isShowingPropertiesView)
                                .transition(.move(edge: .trailing))
                        } else if isShowingResidentsView {
                            ResidentListView(isShowingResidentsView: $isShowingResidentsView)
                                .transition(.move(edge: .trailing))
                        } else if isShowingMaintenanceView {
                            AdminMaintenanceView(isShowingMaintenanceView: $isShowingMaintenanceView, viewModel: maintenanceViewModel)
                                .transition(.move(edge: .trailing))
                        } else {
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
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                QuickActionButton(
                                    icon: "person.2.fill",
                                    title: "Residents",
                                    subtitle: "Manage residents"
                                ) {
                                    isShowingResidentsView = true
                                }
                                
                                QuickActionButton(
                                    icon: "wrench.fill",
                                    title: "Maintenance",
                                    subtitle: "12 Active requests"
                                ) {
                                    isShowingMaintenanceView = true
                                }
                                
                                QuickActionButton(
                                    icon: "building.2.fill",
                                    title: "Amenities",
                                    subtitle: "Manage bookings"
                                ) {
                                    isShowingAmenitiesView = true
                                }
                                
                                QuickActionButton(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Analytics",
                                    subtitle: "View reports"
                                ) {
                                    isShowingAnalyticsView = true
                                }
                                
                                QuickActionButton(
                                    icon: "building.2.fill",
                                    title: "Properties",
                                    subtitle: "Manage properties"
                                ) {
                                    isShowingPropertiesView = true
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Sign Out Button
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
        .animation(.easeInOut(duration: 0.3), value: isShowingPropertiesView)
        .animation(.easeInOut(duration: 0.3), value: isShowingResidentsView)
        .animation(.easeInOut(duration: 0.3), value: isShowingMaintenanceView)
        .animation(.easeInOut(duration: 0.3), value: isShowingAmenitiesView)
        .animation(.easeInOut(duration: 0.3), value: isShowingAnalyticsView)
    }
}
