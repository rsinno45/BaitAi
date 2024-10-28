//
//  PackagesView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

import SwiftUI

struct PackagesView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @Binding var isShowingPackagesView: Bool
    @State private var selectedStatus = 0
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header with Back Button
                    HStack {
                        Button(action: {
                            isShowingPackagesView = false
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(goldColor)
                        }
                        
                        Spacer()
                        
                        Text("Packages")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Package Status Summary
                    HStack(spacing: 15) {
                        PackageStatusCard(title: "Ready", count: "3", icon: "box.truck.fill")
                        PackageStatusCard(title: "Picked Up", count: "12", icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search packages", text: $searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Status Filter
                    Picker("Status", selection: $selectedStatus) {
                        Text("Ready").tag(0)
                        Text("Picked Up").tag(1)
                        Text("All").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Package List
                    VStack(spacing: 15) {
                        ForEach(packages) { package in
                            PackageCard(package: package)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
}

struct Package: Identifiable {
    let id: Int
    let trackingNumber: String
    let carrier: String
    let status: String
    let deliveryDate: String
    let description: String
    let isLarge: Bool
}

struct PackageStatusCard: View {
    let title: String
    let count: String
    let icon: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            Text(count)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PackageCard: View {
    let package: Package
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(package.carrier)
                        .font(.headline)
                    Text(package.trackingNumber)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                PackageStatusBadge(status: package.status)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "calendar")
                Text("Delivered: \(package.deliveryDate)")
                
                Spacer()
                
                if package.isLarge {
                    Label("Large", systemImage: "box.truck.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(goldColor.opacity(0.2))
                        .foregroundColor(goldColor)
                        .cornerRadius(8)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            if package.status == "Ready" {
                Button(action: {
                    // Handle pickup confirmation
                }) {
                    Text("Confirm Pickup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(goldColor)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PackageStatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
        case "Ready": return .green
        case "Picked Up": return .blue
        case "Processing": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}

// Sample Data
let packages = [
    Package(id: 1, trackingNumber: "1Z999AA1234567890", carrier: "UPS", status: "Ready", deliveryDate: "Oct 27", description: "Package from Amazon", isLarge: true),
    Package(id: 2, trackingNumber: "9405511234567890", carrier: "USPS", status: "Ready", deliveryDate: "Oct 26", description: "Small envelope", isLarge: false),
    Package(id: 3, trackingNumber: "7196361234567890", carrier: "FedEx", status: "Picked Up", deliveryDate: "Oct 25", description: "Medium box", isLarge: false),
    Package(id: 4, trackingNumber: "1Z999AA9876543210", carrier: "UPS", status: "Ready", deliveryDate: "Oct 27", description: "Large package", isLarge: true)
]

#Preview {
    PackagesView(isShowingPackagesView: .constant(true))
}
