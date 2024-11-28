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
    private var organizationId: String?
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    
    init() {
        findUserOrganization()
    }
    
    
    private func findUserOrganization() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("organization").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents else { return }
            
            for doc in documents {
                self.db.collection("organization")
                    .document(doc.documentID)
                    .collection("admins")
                    .document(userId)
                    .getDocument { adminDoc, error in
                        if let _ = adminDoc, adminDoc?.exists == true {
                            DispatchQueue.main.async {
                                self.organizationId = doc.documentID
                                print("Found organization: \(doc.documentID)")
                                self.fetchMaintenanceRequests()
                            }
                        }
                    }
            }
        }
    }
    
    func fetchMaintenanceRequests() {
        guard let orgId = organizationId else {
            print("No organization ID found")
            return
        }
        
        isLoading = true
        print("Fetching maintenance requests for organization: \(orgId)")
        
        let maintenanceRef = db.collection("organization")
            .document(orgId)
            .collection("maintenanceReq")
        
        maintenanceRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching maintenance requests: \(error)")
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let documents = snapshot?.documents {
                print("Found \(documents.count) maintenance requests")
                self.requests = documents.compactMap { document -> MaintenanceRequestAdmin? in
                    let data = document.data()
                    return MaintenanceRequestAdmin(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        residentId: data["residentId"] as? String ?? "",
                        status: data["status"] as? String ?? "active",
                        urgency: data["urgency"] as? String ?? "low",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        unitNumber: data["unitNumber"] as? String ?? ""
                    )
                }
                print("Processed \(self.requests.count) requests")
            }
        }
    }
    
    func updateStatus(requestId: String, newStatus: String) {
        guard let orgId = organizationId else { return }
        
        let requestRef = db.collection("organization")
            .document(orgId)
            .collection("maintenanceReq")
            .document(requestId)
        
        requestRef.updateData([
            "status": newStatus.lowercased(),
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error updating status: \(error)")
            } else {
                print("Successfully updated status to: \(newStatus)")
            }
        }
    }
    
    func submitRequest(title: String, description: String, urgency: String, unitNumber: String) {
        guard let orgId = organizationId,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        print("Submitting request for organization: \(orgId)")
        
        let maintenanceRef = db.collection("organization")
            .document(orgId)
            .collection("maintenanceReq")
        
        let newRequest = [
            "title": title,
            "description": description,
            "residentId": userId,
            "status": "active",
            "urgency": urgency,
            "unitNumber": unitNumber,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ] as [String: Any]
        
        maintenanceRef.addDocument(data: newRequest) { error in
            if let error = error {
                print("Error submitting maintenance request: \(error)")
            } else {
                print("Successfully submitted maintenance request")
            }
        }
    }
    
    func fetchMessages(for requestId: String) {
        guard let orgId = organizationId else { return }
        
        let query = db.collection("organization")
            .document(orgId)
            .collection("maintenanceReq")
            .document(requestId)
            .collection("messages")
            .order(by: "timestamp")
        
        listenerRegistrations.append(query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            self.currentMessages = snapshot?.documents.compactMap { document in
                try? document.data(as: MaintenanceMessage.self)
            } ?? []
            
            print("Fetched \(self.currentMessages.count) messages")
        })
    }
    
    func sendMessage(requestId: String, content: String, senderId: String, senderRole: MaintenanceMessage.UserRole) {
        guard let orgId = organizationId else { return }
        
        let messageRef = db.collection("organization")
            .document(orgId)
            .collection("maintenanceReq")
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
    
    func filteredRequests(by status: String) -> [MaintenanceRequestAdmin] {
        return requests.filter { request in
            request.status.lowercased() == status.lowercased()
        }
    }
    
    var activeRequestsCount: Int {
        requests.filter { $0.status.lowercased() == "active" }.count
    }
    
    var completedRequestsCount: Int {
        requests.filter { $0.status.lowercased() == "completed" }.count
    }
    
    func cleanup() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
}
