//
//  MaintenanceView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

import SwiftUI

struct MaintenanceView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @Binding var isShowingMaintenanceView: Bool
    @State private var selectedCategory = 0
    @State private var showingNewRequestSheet = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header with Back Button
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
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Status Overview
                    HStack(spacing: 15) {
                        StatusCard(title: "Active", count: "2", icon: "wrench.fill")
                        StatusCard(title: "Completed", count: "8", icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)
                    
                    // New Request Button
                    Button(action: {
                        showingNewRequestSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Request")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(goldColor)
                        .cornerRadius(12)
                        .shadow(color: goldColor.opacity(0.3), radius: 5, y: 3)
                    }
                    .padding(.horizontal)
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        Text("Active").tag(0)
                        Text("In Progress").tag(1)
                        Text("Completed").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Request List
                    VStack(spacing: 15) {
                        ForEach(maintenanceRequests) { request in
                            MaintenanceRequestCard(request: request)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingNewRequestSheet) {
            NewMaintenanceRequestView(isPresented: $showingNewRequestSheet)
        }
    }
}

struct MaintenanceRequest: Identifiable {
    let id: Int
    let title: String
    let description: String
    let status: String
    let date: String
    let urgency: String
}

struct StatusCard: View {
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

struct MaintenanceRequestCard: View {
    let request: MaintenanceRequest
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(request.title)
                    .font(.headline)
                Spacer()
                StatusBadge(status: request.status)
            }
            
            Text(request.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Label(request.date, systemImage: "calendar")
                Spacer()
                Label(request.urgency, systemImage: "exclamationmark.circle")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
        case "Active": return .orange
        case "In Progress": return .blue
        case "Completed": return .green
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

struct NewMaintenanceRequestView: View {
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var description = ""
    @State private var urgency = 0
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Request Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    Picker("Urgency", selection: $urgency) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                }
            }
            .navigationTitle("New Request")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Submit") {
                    // Handle submission
                    isPresented = false
                }
                .foregroundColor(goldColor)
            )
        }
    }
}

// Sample data
let maintenanceRequests = [
    MaintenanceRequest(id: 1, title: "Leaking Faucet", description: "Kitchen sink faucet is dripping continuously", status: "Active", date: "Today", urgency: "Medium"),
    MaintenanceRequest(id: 2, title: "AC Not Cooling", description: "Air conditioning unit isn't cooling properly", status: "In Progress", date: "Yesterday", urgency: "High"),
    MaintenanceRequest(id: 3, title: "Light Fixture", description: "Bathroom light fixture needs replacement", status: "Completed", date: "Oct 25", urgency: "Low")
]

