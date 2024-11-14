import SwiftUI
import Firebase

struct RefreshableCardModifier: ViewModifier {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.5 : 1.0)
            .scaleEffect(isAnimating ? 0.95 : 1.0)
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnimating = false
                    }
                }
            }
    }
}

struct AdminMaintenanceView: View {
    @Binding var isShowingMaintenanceView: Bool
    let viewModel: MaintenanceRequestViewModel
    @State private var selectedFilter = "Active"
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @State private var isRefreshing = false
    
    let filters = ["Active", "Completed"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: {
                            isShowingMaintenanceView = false
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(goldColor)
                        }
                        
                        Spacer()
                        
                        Text("Maintenance")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Status Overview Cards
                    HStack(spacing: 15) {
                        RequestStatusCard(
                            title: "Active",
                            count: viewModel.activeRequestsCount,
                            icon: "exclamationmark.circle.fill",
                            color: .orange
                        )
                        
                        RequestStatusCard(
                            title: "Completed",
                            count: viewModel.completedRequestsCount,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(filters, id: \.self) { filter in
                                FilterTab(
                                    title: filter,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Request List
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.filteredRequests(by: selectedFilter)) { request in
                                AdminMaintenanceRequestCard(
                                    request: request,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        await refreshData()
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            viewModel.fetchRequests(for: viewModel.currentUserId, isAdmin: true)
        }
    }
    
    func refreshData() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        viewModel.fetchRequests(for: viewModel.currentUserId, isAdmin: true)
    }
}

struct RequestStatusCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.white)
            }
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? goldColor : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct StatusUpdateButton: View {
    let request: MaintenanceRequestAdmin
    let viewModel: MaintenanceRequestViewModel
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @State private var showingCheckmark = false
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            withAnimation {
                isAnimating = true
                showingCheckmark = true
            }
            
            let newStatus = request.status.lowercased() == "active" ? "completed" : "active"
            viewModel.updateStatus(requestId: request.id, newStatus: newStatus)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showingCheckmark = false
                }
            }
        }) {
            ZStack {
                StatusBadgeAdminMaintenance(status: request.status)
                    .opacity(showingCheckmark ? 0 : 1)
                
                if showingCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(RefreshableCardModifier())
    }
}

struct AdminMaintenanceRequestCard: View {
    let request: MaintenanceRequestAdmin
    let viewModel: MaintenanceRequestViewModel
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @State private var showingChatView = false
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    showingChatView = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Unit \(request.unitNumber)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                StatusUpdateButton(request: request, viewModel: viewModel)
                    .padding(8)
            }
            
            Text(request.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Text(formatDate(request.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Label(request.urgency, systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundColor(urgencyColor(request.urgency))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .navigationDestination(isPresented: $showingChatView) {
            MaintenanceChatView(
                viewModel: viewModel,
                request: request,
                currentUserId: viewModel.currentUserId,
                isAdmin: true
            )
        }
        .modifier(RefreshableCardModifier())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func urgencyColor(_ urgency: String) -> Color {
        switch urgency.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
}

struct StatusBadgeAdminMaintenance: View {
    let status: String
    
    var statusColor: Color {
        switch status.lowercased() {
        case "completed": return .green
        default: return .orange
        }
    }
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}
