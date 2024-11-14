import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ResidentViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var unitNumber = ""
    @Published var phoneNumber = ""
    @Published var moveInDate = ""
    @Published var leaseEndDate = ""
    @Published var rentStatus = ""
    
    var initials: String {
        let firstInitial = firstName.prefix(1)
        let lastInitial = lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)"
    }
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data() else { return }
            
            DispatchQueue.main.async {
                self.firstName = data["firstName"] as? String ?? ""
                self.lastName = data["lastName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.unitNumber = data["unitNumber"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.moveInDate = data["moveInDate"] as? String ?? ""
                self.leaseEndDate = data["leaseEndDate"] as? String ?? ""
                self.rentStatus = data["rentStatus"] as? String ?? ""
            }
        }
    }
}
struct ResidentDashboardView: View {
    @StateObject private var viewModel = ResidentViewModel()
    // Define colors
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @State private var isShowingPayRentView = false  // Changed to @State since this is the source
    @State private var isShowingMaintenanceView = false
    @State private var isShowingAmenitiesView = false
    @State private var isShowingPackagesView = false
    
    var body: some View {
        ZStack {  // Main ZStack
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome Back,")
                            .font(.title2)
                        Text("\(viewModel.firstName) \(viewModel.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Profile Image
                    Circle()
                        .fill(goldColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(viewModel.initials)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        )
                }
                .padding()
                .onAppear {
                    viewModel.fetchUserData()
                }
                ScrollView {
                    VStack(spacing: 20) {
                        // Quick Actions Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                            QuickActionButton(
                                icon: "dollarsign.circle.fill",
                                title: "Pay Rent",
                                subtitle: "Due in 5 days"
                            ) {
                                isShowingPayRentView = true
                            }
                            
                            QuickActionButton(
                                icon: "wrench.fill",
                                title: "Maintenance",
                                subtitle: "2 Active Requests"
                            ) {isShowingMaintenanceView = true}
                            
                            QuickActionButton(
                                icon: "calendar",
                                title: "Amenities",
                                subtitle: "Book Now"
                            ) {isShowingAmenitiesView = true}
                            
                            QuickActionButton(
                                icon: "bell.fill",
                                title: "Packages",
                                subtitle: "3 Deliveries"
                            ) {isShowingPackagesView = true}
                        }
                        .padding(.horizontal)
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            ForEach(recentActivities.indices, id: \.self) { index in
                                ActivityCard(
                                    title: recentActivities[index],
                                    time: activityTimes[index],
                                    icon: activityIcons[index]
                                )
                            }
                        }
                        
                        // Important Notices
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Building Notices")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(notices.indices, id: \.self) { index in
                                        NoticeCard(
                                            title: notices[index],
                                            type: noticeTypes[index]
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            // Overlay PayRentView when shown
            if isShowingPayRentView {
                           PayRentView(isShowingPayRentView: $isShowingPayRentView)
                               .transition(.move(edge: .trailing))
                       }
                       if isShowingMaintenanceView {
                           MaintenanceView(isShowingMaintenanceView: $isShowingMaintenanceView)
                               .transition(.move(edge: .trailing))
                       }
                       if isShowingAmenitiesView {
                           AmenitiesView(isShowingAmenitiesView: $isShowingAmenitiesView)
                               .transition(.move(edge: .trailing))
                       }
                       if isShowingPackagesView {
                           PackagesView(isShowingPackagesView: $isShowingPackagesView)
                               .transition(.move(edge: .trailing))
                       }
                   }
                   .animation(.easeInOut(duration: 0.3), value: isShowingPayRentView)
                   .animation(.easeInOut(duration: 0.3), value: isShowingMaintenanceView)
                   .animation(.easeInOut(duration: 0.3), value: isShowingAmenitiesView)
                   .animation(.easeInOut(duration: 0.3), value: isShowingPackagesView)
               }
           }
    // Sample Data
    let recentActivities = [
        "Rent payment confirmed for October",
        "Maintenance request #123 completed",
        "Package delivered to mailroom"
    ]
    
    let activityTimes = ["2h ago", "Yesterday", "2 days ago"]
    let activityIcons = ["dollarsign.circle.fill", "wrench.fill", "box.truck.fill"]
    
    let notices = [
        "Community BBQ This Sunday",
        "Elevator Maintenance Tuesday",
        "Rent Due Reminder"
    ]
    let noticeTypes = ["info", "warning", "alert"]
    


// Supporting Views
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(goldColor)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct ActivityCard: View {
    let title: String
    let time: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color(red: 212/255, green: 175/255, blue: 55/255))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct NoticeCard: View {
    let title: String
    let type: String
    
    var typeColor: Color {
        switch type {
        case "warning": return .orange
        case "alert": return .red
        default: return Color(red: 212/255, green: 175/255, blue: 55/255)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(typeColor)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 150, alignment: .leading)
            
            Text("Tap for details")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 200)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}


