//
//  MessageView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/27/24.
//

import SwiftUI

struct MessageView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text("Messages")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search messages", text: $searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                
                // Message Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        CategoryPill(title: "All", count: "5")
                        CategoryPill(title: "Maintenance", count: "2")
                        CategoryPill(title: "Management", count: "1")
                        CategoryPill(title: "Announcements", count: "2")
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sampleMessages) { message in
                            MessageRow(message: message)
                            
                            if message.id != sampleMessages.last?.id {
                                Divider()
                                    .padding(.leading, 76)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Sample Data
    let sampleMessages = [
        Message(id: 1,
                avatar: "wrench.fill",
                sender: "Maintenance Team",
                preview: "Your request #123 has been completed",
                time: "2m ago",
                unread: true,
                isManagement: false),
        Message(id: 2,
                avatar: "building.2.fill",
                sender: "Property Management",
                preview: "Important: Building maintenance schedule",
                time: "1h ago",
                unread: true,
                isManagement: true),
        Message(id: 3,
                avatar: "megaphone.fill",
                sender: "Community Updates",
                preview: "Weekend events and activities",
                time: "3h ago",
                unread: false,
                isManagement: false),
        Message(id: 4,
                avatar: "wrench.fill",
                sender: "Maintenance Team",
                preview: "Schedule confirmation for tomorrow",
                time: "1d ago",
                unread: false,
                isManagement: false),
        Message(id: 5,
                avatar: "building.2.fill",
                sender: "Property Management",
                preview: "Rent receipt for October",
                time: "2d ago",
                unread: false,
                isManagement: true)
    ]
}

struct Message: Identifiable {
    let id: Int
    let avatar: String
    let sender: String
    let preview: String
    let time: String
    let unread: Bool
    let isManagement: Bool
}

struct CategoryPill: View {
    let title: String
    let count: String
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack {
            Text(title)
            Text(count)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(goldColor)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct MessageRow: View {
    let message: Message
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(message.isManagement ? goldColor : Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: message.avatar)
                        .foregroundColor(message.isManagement ? .white : .gray)
                )
            
            // Message Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.sender)
                        .font(.headline)
                        .foregroundColor(message.unread ? .black : .gray)
                    
                    if message.unread {
                        Circle()
                            .fill(goldColor)
                            .frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                    
                    Text(message.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.preview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(message.unread ? Color.gray.opacity(0.05) : Color.white)
    }
}

#Preview {
    MessageView()
}
