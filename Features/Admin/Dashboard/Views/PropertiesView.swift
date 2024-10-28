//
//  PropertiesView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//
import SwiftUI

struct Property: Identifiable {
    let id: Int
    let name: String
    let address: String
    let units: Int
    let occupancyRate: Double
}

struct PropertiesView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    @Binding var isShowingPropertiesView: Bool
    @State private var showingAddProperty = false
    @State private var searchText = ""
    
    // Sample data
    let properties = [
        Property(id: 1, name: "The Madison", address: "123 Main St", units: 200, occupancyRate: 0.95),
        Property(id: 2, name: "Park View", address: "456 Park Ave", units: 150, occupancyRate: 0.88),
        Property(id: 3, name: "River Heights", address: "789 River Rd", units: 175, occupancyRate: 0.92)
    ]
    
    var body: some View {
        ZStack {
            // Black background for admin
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
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search properties", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Properties Overview
                HStack(spacing: 15) {
                    PropertyStatCard(title: "Total Properties", value: "\(properties.count)")
                    PropertyStatCard(title: "Total Units", value: "\(properties.reduce(0) { $0 + $1.units })")
                }
                .padding(.horizontal)
                
                // Properties List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(properties) { property in
                            PropertyCard(property: property)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingAddProperty) {
            AddPropertyView(isPresented: $showingAddProperty)
        }
    }
}

struct PropertyStatCard: View {
    let title: String
    let value: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PropertyCard: View {
    let property: Property
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(property.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                OccupancyBadge(rate: property.occupancyRate)
            }
            
            Divider()
                .background(Color.gray)
            
            HStack {
                Text("\(property.units) Units")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Manage →")
                        .font(.caption)
                        .foregroundColor(goldColor)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct OccupancyBadge: View {
    let rate: Double
    
    var color: Color {
        switch rate {
        case 0.9...: return .green
        case 0.7..<0.9: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        Text("\(Int(rate * 100))% Occupied")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct AddPropertyView: View {
    @Binding var isPresented: Bool
    @State private var propertyName = ""
    @State private var address = ""
    @State private var units = ""
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Name", text: $propertyName)
                    TextField("Address", text: $address)
                    TextField("Number of Units", text: $units)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    // Handle adding property
                    isPresented = false
                }
                .foregroundColor(goldColor)
            )
        }
    }
}
