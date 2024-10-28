//
//  AmenitiesView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/28/24.
//

import SwiftUI

struct AmenitiesView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @Binding var isShowingAmenitiesView: Bool
    @State private var selectedDate = Date()
    @State private var showingBookingSheet = false
    @State private var selectedAmenity: Amenity?
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header with Back Button
                    HStack {
                        Button(action: {
                            isShowingAmenitiesView = false
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(goldColor)
                        }
                        
                        Spacer()
                        
                        Text("Amenities")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // My Bookings Summary
                    HStack(spacing: 15) {
                        BookingSummaryCard(title: "Active Bookings", count: "2")
                        BookingSummaryCard(title: "Past Bookings", count: "8")
                    }
                    .padding(.horizontal)
                    
                    // Featured Amenities
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Featured Amenities")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(featuredAmenities) { amenity in
                                    FeaturedAmenityCard(amenity: amenity) {
                                        selectedAmenity = amenity
                                        showingBookingSheet = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // All Amenities
                    VStack(alignment: .leading, spacing: 15) {
                        Text("All Amenities")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(allAmenities) { amenity in
                            AmenityListItem(amenity: amenity) {
                                selectedAmenity = amenity
                                showingBookingSheet = true
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingBookingSheet) {
            if let amenity = selectedAmenity {
                BookingView(amenity: amenity, isPresented: $showingBookingSheet)
            }
        }
    }
}

struct Amenity: Identifiable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let capacity: String
    let hours: String
    let isFeatured: Bool
}

struct BookingSummaryCard: View {
    let title: String
    let count: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
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

struct FeaturedAmenityCard: View {
    let amenity: Amenity
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: amenity.icon)
                    .font(.title)
                    .foregroundColor(goldColor)
                
                Text(amenity.name)
                    .font(.headline)
                
                Text(amenity.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text("Book Now →")
                    .font(.caption)
                    .foregroundColor(goldColor)
            }
            .frame(width: 200)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct AmenityListItem: View {
    let amenity: Amenity
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: amenity.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(goldColor)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(amenity.name)
                        .font(.headline)
                    
                    Text(amenity.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct BookingView: View {
    let amenity: Amenity
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = 0
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Booking Details")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    Picker("Time Slot", selection: $selectedTimeSlot) {
                        Text("Morning (9AM-12PM)").tag(0)
                        Text("Afternoon (1PM-4PM)").tag(1)
                        Text("Evening (5PM-8PM)").tag(2)
                    }
                }
                
                Section(header: Text("Amenity Info")) {
                    HStack {
                        Text("Capacity")
                        Spacer()
                        Text(amenity.capacity)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Hours")
                        Spacer()
                        Text(amenity.hours)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Book \(amenity.name)")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Book") {
                    // Handle booking
                    isPresented = false
                }
                .foregroundColor(goldColor)
            )
        }
    }
}

// Sample Data
let featuredAmenities = [
    Amenity(id: 1, name: "Fitness Center", description: "State-of-the-art equipment and free weights", icon: "dumbbell.fill", capacity: "25 people", hours: "24/7", isFeatured: true),
    Amenity(id: 2, name: "Pool", description: "Heated pool with lounging area", icon: "figure.pool.swim", capacity: "30 people", hours: "6AM-10PM", isFeatured: true),
    Amenity(id: 3, name: "BBQ Area", description: "Outdoor grilling and dining space", icon: "flame.fill", capacity: "20 people", hours: "9AM-9PM", isFeatured: true)
]

let allAmenities = [
    Amenity(id: 1, name: "Fitness Center", description: "State-of-the-art equipment and free weights", icon: "dumbbell.fill", capacity: "25 people", hours: "24/7", isFeatured: true),
    Amenity(id: 2, name: "Pool", description: "Heated pool with lounging area", icon: "figure.pool.swim", capacity: "30 people", hours: "6AM-10PM", isFeatured: true),
    Amenity(id: 3, name: "BBQ Area", description: "Outdoor grilling and dining space", icon: "flame.fill", capacity: "20 people", hours: "9AM-9PM", isFeatured: true),
    Amenity(id: 4, name: "Conference Room", description: "Private meeting space", icon: "person.3.fill", capacity: "12 people", hours: "8AM-8PM", isFeatured: false),
    Amenity(id: 5, name: "Movie Theater", description: "Private screening room", icon: "tv.fill", capacity: "15 people", hours: "10AM-11PM", isFeatured: false)
]


