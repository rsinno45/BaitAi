//
//  MaintenanceChatView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 11/12/24.
//

import SwiftUI

struct MaintenanceChatView: View {
    let viewModel: MaintenanceRequestViewModel
    let request: MaintenanceRequestAdmin
    let currentUserId: String
    let isAdmin: Bool
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            MaintenanceChatHeader(request: request)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.currentMessages) { message in
                            MaintenanceChatBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == currentUserId
                            )
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: viewModel.currentMessages.count) { _ in
                    scrollToBottom()
                }
            }
            
            // Message Input
            MaintenanceChatInput(
                messageText: $messageText,
                onSend: sendMessage
            )
        }
        .onAppear {
            viewModel.fetchMessages(for: request.id)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private func scrollToBottom() {
        if let last = viewModel.currentMessages.last {
            scrollProxy?.scrollTo(last.id, anchor: .bottom)
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.sendMessage(
            requestId: request.id,
            content: messageText,
            senderId: currentUserId,
            senderRole: isAdmin ? .admin : .resident
        )
        
        messageText = ""
    }
}

// Header Component
struct MaintenanceChatHeader: View {
    let request: MaintenanceRequestAdmin
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(request.title)
                        .font(.headline)
                    Text("Request #\(request.id.prefix(6))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadgeMaintenance(status: request.status) // Remove .rawValue here
            }
            .padding()
            
            Divider()
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 5)
    }
}
// Chat Bubble Component
struct MaintenanceChatBubble: View {
    let message: MaintenanceMessage
    let isFromCurrentUser: Bool
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? goldColor : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                Text(formatDate(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Message Input Component
struct MaintenanceChatInput: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        HStack(spacing: 12) {
            // Future: Add attachment button here
            
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : goldColor)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: -5)
    }
}

struct StatusBadgeMaintenance: View {
    let status: String  // Changed from accessing rawValue
    
    var statusColor: Color {
            status.lowercased() == "completed" ? .green : .orange
        }

    var body: some View {
            Text(status.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(8)
        }
}

