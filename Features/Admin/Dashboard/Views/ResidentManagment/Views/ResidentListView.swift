import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - View Models
class ResidentListViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var residents: [Resident] = []
    @Published var properties: [Property] = []
    @Published var selectedPropertyId: String?
    @Published var filters = ResidentFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var organizationId: String?
    
    private var db = Firestore.firestore()
    private var adminEmail: String?
    private var adminPassword: String?
    
    func setAdminCredentials(email: String, password: String) {
            self.adminEmail = email
            self.adminPassword = password
        }


    
    private var currentAdminId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
            findUserOrganization()
        }

    
    var filteredResidents: [Resident] {
        var filtered = residents
        
        // Apply property filter
        if let propertyId = selectedPropertyId {
            filtered = filtered.filter { $0.propertyId == propertyId }
        }
        
        // Apply status filter
        if filters.filterStatus != .all {
            filtered = filtered.filter { $0.status == filters.filterStatus }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.firstName.localizedCaseInsensitiveContains(searchText) ||
                $0.lastName.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
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
                                self.organizationId = doc.documentID
                                self.fetchResidents()
                                self.fetchProperties()
                            }
                        }
                }
            }
        }

    
    func fetchProperties() {
        guard let orgId = organizationId else { return }
        
        db.collection("organization")
            .document(orgId)
            .collection("properties")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.properties = snapshot?.documents.compactMap { document in
                    try? document.data(as: Property.self)
                } ?? []
            }
    }
    func addResident(_ resident: Resident) {
        guard let orgId = organizationId else { return }
        guard let currentAdmin = Auth.auth().currentUser else { return }
        
        let temporaryPassword = resident.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        Auth.auth().createUser(withEmail: resident.email, password: temporaryPassword) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let firebaseUser = result?.user else { return }
            
            let batch = self.db.batch()
            
            // Add to residents collection
            let residentRef = self.db.collection("organization")
                .document(orgId)
                .collection("residents")
                .document(firebaseUser.uid)
            
            let residentData: [String: Any] = [
                "firstName": resident.firstName,
                "lastName": resident.lastName,
                "email": resident.email,
                "phone": resident.phone,
                "unitNumber": resident.unitNumber,
                "propertyId": resident.propertyId,
                "status": resident.status.rawValue,
                "createdAt": Timestamp(date: Date()),
                "organizationId": orgId,
                "firebaseUID": firebaseUser.uid
            ]
            
            batch.setData(residentData, forDocument: residentRef)
            
            batch.commit { [weak self] error in
                if let error = error {
                    print("Error writing batch: \(error)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Sign back in as the admin using stored credentials
                if let adminEmail = UserCredentials.shared.email,
                   let adminPassword = UserCredentials.shared.password {
                    Auth.auth().signIn(withEmail: adminEmail, password: adminPassword) { _, error in
                        if let error = error {
                            print("Error signing back in as admin: \(error)")
                            return
                        }
                        
                        // Now send the password reset email
                        Auth.auth().sendPasswordReset(withEmail: resident.email) { error in
                            if let error = error {
                                print("Error sending password reset: \(error)")
                                return
                            }
                            print("Password reset email sent successfully")
                        }
                        
                        self?.fetchResidents()
                    }
                } else {
                    print("Error: No admin credentials stored")
                }
            }
        }
    }
    private func createPendingUserAccount(email: String, propertyId: String, temporaryPassword: String) {
        // First get the company name for the current admin
        guard let adminId = currentAdminId else { return }
        
        db.collection("companies")
            .whereField("adminId", isEqualTo: adminId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching company: \(error)")
                    return
                }
                
                guard let companyDoc = snapshot?.documents.first,
                      let companyName = companyDoc.data()["name"] as? String else {
                    print("No company found for admin")
                    return
                }
                
                let userData: [String: Any] = [
                    "email": email,
                    "propertyId": propertyId,
                    "status": "pending",
                    "role": "resident",
                    "initialPassword": "Your phone number without any special characters",
                    "createdAt": Timestamp(date: Date())
                ]
                
                // Use the nested path with company name
                self?.db.collection("companies")
                    .document(companyName)
                    .collection("users")
                    .document(email)
                    .setData(userData) { error in
                        if let error = error {
                            print("Error creating pending user: \(error)")
                        } else {
                            print("Successfully created pending user under company: \(companyName)")
                        }
                    }
            }
    }
    
    func fetchResidents() {
            guard let orgId = organizationId else { return }
            
            isLoading = true
            
            db.collection("organization")
                .document(orgId)
                .collection("residents")
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let snapshot = snapshot {
                        self.residents = snapshot.documents.compactMap { document in
                            let resident = Resident(document: document)
                            return resident
                        }
                    }
                }
        }
}

struct ResidentListView: View {
    @Binding var isShowingResidentsView: Bool
    @StateObject private var viewModel = ResidentListViewModel()
    @State private var showingFilters = false
    @State private var showingAddResident = false
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        isShowingResidentsView = false
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(goldColor)
                    }
                    
                    Spacer()
                    
                    Text("Residents")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddResident = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(goldColor)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // Search Bar
                ResidentSearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Property Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.properties) { property in
                            PropertyFilterChip(
                                propertyName: property.name,
                                isSelected: viewModel.selectedPropertyId == property.id
                            ) {
                                viewModel.selectedPropertyId = property.id
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Residents List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredResidents) { resident in
                            NavigationLink(destination: ResidentDetailView(viewModel: ResidentDetailViewModel(resident: resident))) {
                                ResidentRowView(resident: resident)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingAddResident) {
            AddResidentView(viewModel: viewModel)
        }
    }
}

struct AddResidentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ResidentListViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var unitNumber = ""
    @State private var selectedProperty: Property?
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Resident Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Unit Number", text: $unitNumber)
                }
                
                Section(header: Text("Property Assignment")) {
                    if viewModel.properties.isEmpty {
                        Text("No properties available")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Property", selection: $selectedProperty) {
                            Text("Select a property").tag(Optional<Property>.none)
                            ForEach(viewModel.properties) { property in
                                Text(property.name).tag(Optional(property))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Resident")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    addResident()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        !unitNumber.isEmpty &&
        selectedProperty != nil
    }
    
    private func addResident() {
        guard let property = selectedProperty,
              let orgId = viewModel.organizationId else { return }
        
        let newResident = Resident(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            unitNumber: unitNumber,
            propertyId: property.id,
            status: .pending,
            organizationId: orgId
        )
        
        viewModel.addResident(newResident)
        dismiss()
    }
}

struct PropertyFilterChip: View {
    let propertyName: String
    let isSelected: Bool
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            Text(propertyName)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? goldColor : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(20)
        }
    }
}

// MARK: - ResidentDetailView and ViewModel
class ResidentDetailViewModel: ObservableObject {
    @Published var resident: Resident?
    @Published var leaseDetails: LeaseDetails?
    @Published var payments: [Payment] = []
    @Published var documents: [ResidentDocument] = []
    @Published var maintenanceRequests: [MaintenanceRequest] = []
    @Published var showingEditSheet = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    init(resident: Resident) {
        self.resident = resident
        fetchResidentDetails()
    }
    
    func fetchResidentDetails() {
        isLoading = true
        
        fetchLeaseDetails()
        fetchPayments()
        fetchDocuments()
        fetchMaintenanceRequests()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    func fetchLeaseDetails() {
        guard let resident = resident else { return }
        
        db.collection("leases")
            .whereField("residentId", isEqualTo: resident.id)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let document = snapshot?.documents.first {
                    do {
                        self.leaseDetails = try document.data(as: LeaseDetails.self)
                    } catch {
                        print("Error decoding lease details: \(error)")
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }

    func fetchPayments() {
        guard let resident = resident else { return }
        
        db.collection("payments")
            .whereField("residentId", isEqualTo: resident.id)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.payments = snapshot?.documents.compactMap { document in
                    try? document.data(as: Payment.self)
                } ?? []
            }
    }
    
    func fetchDocuments() {
        guard let resident = resident else { return }
        
        db.collection("documents")
            .whereField("residentId", isEqualTo: resident.id)
            .order(by: "uploadDate", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.documents = snapshot?.documents.compactMap { document in
                    try? document.data(as: ResidentDocument.self)
                } ?? []
            }
    }
    
    func fetchMaintenanceRequests() {
        guard let resident = resident else { return }
        
        db.collection("maintenanceRequests")
            .whereField("residentId", isEqualTo: resident.id)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.maintenanceRequests = snapshot?.documents.compactMap { document in
                    try? document.data(as: MaintenanceRequest.self)
                } ?? []
            }
    }
}


