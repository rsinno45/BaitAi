//
//  ResidentDetailView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ResidentDetailViewModel
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(goldColor)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showingEditSheet = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(goldColor)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Content Sections
                    Group {
                        if let resident = viewModel.resident {
                            ResidentInfoSection(resident: resident)
                        }
                        
                        if let leaseDetails = viewModel.leaseDetails {
                            LeaseDetailsSection(lease: leaseDetails)
                        }
                        
                        if !viewModel.payments.isEmpty {
                            PaymentHistorySection(payments: viewModel.payments)
                        }
                        
                        if !viewModel.maintenanceRequests.isEmpty {
                            MaintenanceHistorySection(requests: viewModel.maintenanceRequests)
                        }
                        
                        if !viewModel.documents.isEmpty {
                            DocumentsSection(documents: viewModel.documents)
                        }
                    }
                }
                .padding(.vertical)
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: goldColor))
                    .scaleEffect(1.5)
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            EditResidentView(viewModel: viewModel)
        }
    }
}
