import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

class MaintenanceRequestViewModel: ObservableObject {
    @Published var requests: [MaintenanceRequestAdmin] = []
    @Published var currentMessages: [MaintenanceMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    private var listenerRegistrations: [ListenerRegistration] = []

    var currentCompanyId: String? {
            let id = UserDefaults.standard.string(forKey: "currentCompanyId")
            print("Current Company ID: \(id ?? "nil")")
            return id ?? "defaultCompanyId" // Temporarily return a default for testing
        }

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    // MARK: - Initialization
    init() {
        fetchResidentRequests()
    }
    
    // MARK: - Status Management
    func updateStatus(requestId: String, newStatus: String) {
        db.collection("maintenanceRequests").document(requestId).updateData([
            "status": newStatus.lowercased(),
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error updating status: \(error)")
            } else {
                print("Status updated successfully to: \(newStatus)")
                // Refresh the requests after update
                self.fetchRequests(for: self.currentUserId, isAdmin: true)
            }
        }
    }
    
    // MARK: - Request Filtering
    func filteredRequests(by status: String) -> [MaintenanceRequestAdmin] {
        return requests.filter { request in
            request.status.lowercased() == status.lowercased()
        }
    }
    
    // MARK: - Fetch Requests
    func fetchRequests(for userId: String, isAdmin: Bool) {
            print("Fetching requests for user: \(userId), isAdmin: \(isAdmin)")
            
            let query = db.collection("maintenanceRequests")
            // Temporarily remove company filter to see if data exists
            
            query.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching requests: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    print("Found \(documents.count) total documents")
                    documents.forEach { doc in
                        print("Document data: \(doc.data())")
                    }
                    
                    self.requests = documents.compactMap { document -> MaintenanceRequestAdmin? in
                        let data = document.data()
                        return MaintenanceRequestAdmin(
                            id: document.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            residentId: data["residentId"] as? String ?? "",
                            propertyId: data["propertyId"] as? String ?? "",
                            status: data["status"] as? String ?? "active",
                            urgency: data["urgency"] as? String ?? "low",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                            unitNumber: data["unitNumber"] as? String ?? "",
                            companyId: data["companyId"] as? String ?? self.currentCompanyId ?? ""
                        )
                    }
                    
                    print("Processed \(self.requests.count) requests")
                } else {
                    print("No documents found")
                }
            }
        }

    private func fetchAdminCompany(_ adminId: String, completion: @escaping (String) -> Void) {
        db.collection("companies")
            .whereField("adminId", isEqualTo: adminId)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first,
                   let companyId = document.data()["id"] as? String {
                    UserDefaults.standard.set(companyId, forKey: "currentCompanyId")
                    completion(companyId)
                }
            }
    }
    
    private func fetchRequestsForCompany(_ companyId: String) {
        isLoading = true
        print("Fetching requests for company: \(companyId)")
        
        db.collection("maintenanceRequests")
            .whereField("companyId", isEqualTo: companyId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching requests: \(error)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let documents = snapshot?.documents {
                    print("Found \(documents.count) documents")
                    
                    self.requests = documents.compactMap { document -> MaintenanceRequestAdmin? in
                        let data = document.data()
                        return MaintenanceRequestAdmin(
                            id: document.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            residentId: data["residentId"] as? String ?? "",
                            propertyId: data["propertyId"] as? String ?? "",
                            status: data["status"] as? String ?? "active",
                            urgency: data["urgency"] as? String ?? "low",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                            unitNumber: data["unitNumber"] as? String ?? "",
                            companyId: data["companyId"] as? String ?? companyId
                        )
                    }
                    
                    print("Processed \(self.requests.count) requests")
                }
            }
    }
    
    // MARK: - Messages Management
    func fetchMessages(for requestId: String) {
        let query = db.collection("maintenanceRequests")
            .document(requestId)
            .collection("messages")
            .order(by: "timestamp")
        
        listenerRegistrations.append(query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.currentMessages = snapshot?.documents.compactMap { document in
                try? document.data(as: MaintenanceMessage.self)
            } ?? []
        })
    }
    
    func sendMessage(requestId: String, content: String, senderId: String, senderRole: MaintenanceMessage.UserRole) {
        let messageRef = db.collection("maintenanceRequests")
            .document(requestId)
            .collection("messages")
            .document()
        
        let message = MaintenanceMessage(
            id: messageRef.documentID,
            requestId: requestId,
            senderId: senderId,
            senderRole: senderRole,
            content: content,
            timestamp: Date(),
            isRead: false
        )
        
        try? messageRef.setData(from: message)
    }
    
    // MARK: - Resident Requests
    func fetchResidentRequests() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found")
                return
            }
            
            print("Fetching resident requests for user: \(userId)")
            
            let query = db.collection("maintenanceRequests")
                .whereField("residentId", isEqualTo: userId)
            // Temporarily remove company filter
            
            query.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching resident requests: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    print("Found \(documents.count) resident documents")
                    documents.forEach { doc in
                        print("Resident request data: \(doc.data())")
                    }
                    
                    self.requests = documents.compactMap { document -> MaintenanceRequestAdmin? in
                        let data = document.data()
                        return MaintenanceRequestAdmin(
                            id: document.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            residentId: data["residentId"] as? String ?? "",
                            propertyId: data["propertyId"] as? String ?? "",
                            status: data["status"] as? String ?? "active",
                            urgency: data["urgency"] as? String ?? "low",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                            unitNumber: data["unitNumber"] as? String ?? "",
                            companyId: data["companyId"] as? String ?? self.currentCompanyId ?? ""
                        )
                    }
                    
                    print("Processed \(self.requests.count) resident requests")
                } else {
                    print("No resident documents found")
                }
            }
        }


    // MARK: - Request Counts
    var activeRequestsCount: Int {
        requests.filter { $0.status.lowercased() == "active" }.count
    }
    
    var completedRequestsCount: Int {
        requests.filter { $0.status.lowercased() == "completed" }.count
    }
    
    // MARK: - Submit New Request
    func submitRequest(title: String, description: String, urgency: Int) {
        guard let userId = Auth.auth().currentUser?.uid,
              let companyId = currentCompanyId else { return }
        
        let now = Date()
        let newRequest = [
            "title": title,
            "description": description,
            "residentId": userId,
            "propertyId": "",
            "status": "active",
            "urgency": urgencyToString(urgency),
            "createdAt": Timestamp(date: now),
            "updatedAt": Timestamp(date: now),
            "unitNumber": "",
            "companyId": companyId
        ] as [String: Any]
        
        db.collection("maintenanceRequests").addDocument(data: newRequest)
    }
    
    private func urgencyToString(_ urgency: Int) -> String {
        switch urgency {
        case 0: return "low"
        case 1: return "medium"
        case 2: return "high"
        default: return "low"
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
}


