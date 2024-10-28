//
//  BaitAiApp.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/26/24.
//

import SwiftUI

@main
struct BaitAiApp: App {
    @State private var isAuthenticated = false
    @State private var isAdmin = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAuthenticated {
                    if isAdmin {
                        AdminDashboardView(isAuthenticated: $isAuthenticated)
                            .transition(.move(edge: .trailing))
                    } else {
                        MainTabView(isAuthenticated: $isAuthenticated)
                            .transition(.move(edge: .trailing))
                    }
                } else {
                    AuthView(isAuthenticated: $isAuthenticated, isAdmin: $isAdmin)
                        .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isAuthenticated)
        }
    }
}
