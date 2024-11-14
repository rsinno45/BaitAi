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
    @StateObject private var viewModel = MaintenanceRequestViewModel()
    
    var filteredRequests: [MaintenanceRequestAdmin] {
            switch selectedCategory {
            case 0: return viewModel.requests.filter { $0.status.lowercased() == "active" }
            case 1: return viewModel.requests.filter { $0.status.lowercased() == "completed" }
            default: return []
            }
        }

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
                        StatusCard(
                            title: "Active",
                            count: "\(viewModel.requests.filter { $0.status == "active" }.count)",
                            icon: "wrench.fill"
                        )
                        StatusCard(
                            title: "Completed",
                            count: "\(viewModel.requests.filter { $0.status == "completed" }.count)",
                            icon: "checkmark.circle.fill"
                        )
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
                                Text("Completed").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)

                    // Request List
                    VStack(spacing: 15) {
                        ForEach(filteredRequests) { request in
                            MaintenanceRequestCard(request: request)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .sheet(isPresented: $showingNewRequestSheet) {
            NewMaintenanceRequestView(
                isPresented: $showingNewRequestSheet,
                viewModel: viewModel
            )
        }
    }
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
    let request: MaintenanceRequestAdmin
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
               // Label(request.date, systemImage: "calendar")
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
    let viewModel: MaintenanceRequestViewModel  // Remove @ObservedObject
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
                                viewModel.submitRequest(  // Updated function name
                                    title: title,
                                    description: description,
                                    urgency: urgency
                                )
                                isPresented = false
                            }
                            .disabled(title.isEmpty || description.isEmpty)
                        )
                    }
                }
            }
    
    

    
    // Sample data

