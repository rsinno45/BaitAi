import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - View Models
class ResidentListViewModel: ObservableObject {
    @Published var residents: [Resident] = []
    @Published var properties: [Property] = []
    @Published var selectedPropertyId: String?
    @Published var filters = ResidentFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private var db = Firestore.firestore()
    private var currentAdminId: String? {
        Auth.auth().currentUser?.uid
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
    
    func fetchProperties() {
        guard let adminId = currentAdminId else { return }
        print("Fetching properties for admin: \(adminId)")
        
        db.collection("properties")
            .whereField("adminId", isEqualTo: adminId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching properties: \(error)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.properties = snapshot?.documents.compactMap { document in
                    try? document.data(as: Property.self)
                } ?? []
                
                print("Fetched \(self.properties.count) properties")
            }
    }
    
    func addResident(_ resident: Resident) {
        guard let adminId = currentAdminId else { return }
        
        // Clean the phone number to use as password (same as before)
        let temporaryPassword = resident.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Create Firebase Auth user (same as before)
        Auth.auth().createUser(withEmail: resident.email, password: temporaryPassword) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error creating user: \(error)")
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let firebaseUser = result?.user else { return }
            
            // 1. Create resident document (same as before)
            let docRef = self.db.collection("residents").document()
            
            let residentData: [String: Any] = [
                "firstName": resident.firstName,
                "lastName": resident.lastName,
                "email": resident.email,
                "phone": resident.phone,
                "unitNumber": resident.unitNumber,
                "propertyId": resident.propertyId,
                "status": resident.status.rawValue,
                "createdAt": Timestamp(date: Date()),
                "adminId": adminId,
                "firebaseUID": firebaseUser.uid
            ]
            
            // 2. Create user document (NEW!)
            let userData: [String: Any] = [
                "email": resident.email,
                "firstName": resident.firstName,
                "lastName": resident.lastName,
                "unitNumber": resident.unitNumber,
                "role": "resident",
                "createdAt": Timestamp(date: Date()),
                "phoneNumber": resident.phone,
                "propertyId": resident.propertyId,
                "status": resident.status.rawValue
            ]
            
            // Start a batch write
            let batch = self.db.batch()
            
            // Add resident document to batch
            batch.setData(residentData, forDocument: docRef)
            
            // Add user document to batch
            let userRef = self.db.collection("users").document(firebaseUser.uid)
            batch.setData(userData, forDocument: userRef)
            
            // Commit the batch
            batch.commit { [weak self] error in
                if let error = error {
                    print("Error writing batch: \(error)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Continue with existing code...
                self?.createPendingUserAccount(
                    email: resident.email,
                    propertyId: resident.propertyId,
                    temporaryPassword: temporaryPassword
                )
                
                // Send password reset email
                Auth.auth().sendPasswordReset(withEmail: resident.email) { error in
                    if let error = error {
                        print("Error sending password reset: \(error)")
                        return
                    }
                    print("Password reset email sent successfully")
                }
                
                self?.fetchResidents()
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
            guard let adminId = currentAdminId else {
                print("No admin ID found")
                return
            }
            
            isLoading = true
            print("Fetching residents for admin: \(adminId)")
            
            // Fetch properties first
            fetchProperties()
            
            // Then fetch residents with real-time updates
            db.collection("residents")
                .whereField("adminId", isEqualTo: adminId)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error fetching residents: \(error)")
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let snapshot = snapshot {
                        print("Got \(snapshot.documents.count) residents")
                        self.residents = snapshot.documents.compactMap { document in
                            // Use the new document initializer
                            let resident = Resident(document: document)
                            print("Parsed resident: \(resident?.firstName ?? "unknown") \(resident?.lastName ?? "unknown")")
                            return resident
                        }
                        print("Parsed \(self.residents.count) residents")
                    }
                }
        }
}

// MARK: - Views
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
                    VStack(spacing: 12) {
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
            
            // Loading State
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: goldColor))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
            }
            
            // Filter Sheet
            if showingFilters {
                ResidentFilterView(
                    isPresented: $showingFilters,
                    filters: $viewModel.filters
                )
            }
        }
        .sheet(isPresented: $showingAddResident) {
            AddResidentView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchResidents()
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
    @State private var adminId = ""
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
        guard let property = selectedProperty else { return }
        
        let newResident = Resident(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            unitNumber: unitNumber,
            propertyId: property.id,
            status: .pending, adminId: adminId
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


