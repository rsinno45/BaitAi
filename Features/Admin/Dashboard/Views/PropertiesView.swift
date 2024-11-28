//
//  PropertiesView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//
import SwiftUI
import Firebase
import FirebaseAuth


struct PropertiesView: View {
    @Binding var isShowingPropertiesView: Bool
    @StateObject private var viewModel = PropertiesViewModel()
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @State private var showingAddProperty = false
    @State private var selectedProperty: Property?  // Add this
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header with Back Button
                HStack {
                    Button(action: {
                        isShowingPropertiesView = false
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(goldColor)
                    }
                    
                    Spacer()
                    
                    Text("Properties")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddProperty = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(goldColor)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.properties) { property in
                            PropertyCard(property: property) {
                                selectedProperty = property  // Just store selected property
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingAddProperty) {
            AddPropertyView(viewModel: viewModel)
        }
    }
}

class PropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var organizationId: String?
    private let db = Firestore.firestore()
    
    init() {
        findUserOrganization()
    }
    
    private func findUserOrganization() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No current user found")
            return
        }
        print("👤 Current user ID: \(userId)")
        print("📱 Finding organization for user: \(userId)")
        
        // Let's also log the current user's email to verify it's the admin
        if let email = Auth.auth().currentUser?.email {
            print("📧 Current user email: \(email)")
        }
        
        db.collection("organization").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents else {
                print("❌ Error getting documents: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            print("📚 Found \(documents.count) organizations")
            
            for doc in documents {
                print("🔍 Checking organization: \(doc.documentID)")
                self.db.collection("organization")
                    .document(doc.documentID)
                    .collection("admins")
                    .document(userId)
                    .getDocument { adminDoc, error in
                        if let error = error {
                            print("❌ Error checking admin status: \(error.localizedDescription)")
                            return
                        }
                        
                        if let _ = adminDoc, adminDoc?.exists == true {
                            print("✅ Found admin in organization: \(doc.documentID)")
                            self.organizationId = doc.documentID
                            self.fetchProperties()
                        } else {
                            print("❌ User \(userId) is not an admin in org \(doc.documentID)")
                        }
                    }
            }
        }
    }
    func fetchProperties() {
        guard let orgId = organizationId else {
            print("No organization ID found")
            return
        }
        
        print("Fetching properties for organization: \(orgId)")
        
        db.collection("organization")
            .document(orgId)
            .collection("properties")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No properties found or error: \(error?.localizedDescription ?? "")")
                    return
                }
                
                print("Found \(documents.count) properties")
                
                DispatchQueue.main.async {
                    self?.properties = documents.compactMap { document -> Property? in
                        var property = try? document.data(as: Property.self)
                        property?.id = document.documentID
                        return property
                    }
                }
            }
    }
    
    func addProperty(_ propertyData: PropertyData) {
        guard let orgId = organizationId else {
            print("No organization ID found")
            return
        }
        
        print("Adding property to organization: \(orgId)")
        
        let property = Property(
            name: propertyData.name,
            address: propertyData.address,
            units: propertyData.units,
            amenities: propertyData.amenities,
            organizationId: orgId
        )
        
        do {
            _ = try db.collection("organization")
                .document(orgId)
                .collection("properties")
                .addDocument(from: property)
            print("Successfully added property")
        } catch {
            print("Error adding property: \(error)")
        }
    }
}


struct PropertyData {
    var name: String
    var address: String
    var units: Int
    var amenities: [String]
}

// Update Property model to have optional ID
struct Property: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var address: String
    var units: Int
    var amenities: [String]
    var organizationId: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Property, rhs: Property) -> Bool {
        lhs.id == rhs.id
    }
}

struct AddPropertyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PropertiesViewModel
    @State private var propertyName = ""
    @State private var address = ""
    @State private var units = ""
    @State private var amenities = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Name", text: $propertyName)
                    TextField("Address", text: $address)
                    TextField("Number of Units", text: $units)
                        .keyboardType(.numberPad)
                    TextField("Amenities (comma separated)", text: $amenities)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let propertyData = PropertyData(
                        name: propertyName,
                        address: address,
                        units: Int(units) ?? 0,
                        amenities: amenities.components(separatedBy: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                    )
                    viewModel.addProperty(propertyData)
                    dismiss()
                }
            )
        }
    }
}

struct PropertyCard: View {
    let property: Property
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(property.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("\(property.units) Units")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Manage →")
                        .font(.caption)
                        .foregroundColor(goldColor)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
}
