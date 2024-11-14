//
//  ResidentFilterView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct ResidentFilters {
    var sortBy: SortOption = .name
    var filterStatus: ResidentStatus = .all
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case unit = "Unit"
    case moveIn = "Move-in Date"
}



enum LeaseStatus: String, CaseIterable {
    case all = "All"
    case current = "Current"
    case ending = "Ending Soon"
    case expired = "Expired"
}

struct ResidentFilterView: View {
    @Binding var isPresented: Bool
    @Binding var filters: ResidentFilters
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Filters")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(goldColor)
                            .font(.title2)
                    }
                }
                
                // Filter Options
                VStack(alignment: .leading, spacing: 20) {
                    filterSection(title: "Sort By") {
                        Picker("Sort By", selection: $filters.sortBy) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    filterSection(title: "Resident Status") {
                        Picker("Status", selection: $filters.filterStatus) {
                            ForEach(ResidentStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                
                Spacer()
                
                // Apply Button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Apply Filters")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(goldColor)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            content()
        }
    }
}

