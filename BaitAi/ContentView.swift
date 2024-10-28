//
//  ContentView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/27/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var isAuthenticated: Bool
    @Binding var isAdmin: Bool
    
    var body: some View {
        ZStack {
            if isAuthenticated {
                MainTabView(isAuthenticated: $isAuthenticated)
                    .transition(.move(edge: .trailing))
            } else {
                AuthView(isAuthenticated: $isAuthenticated, isAdmin: $isAdmin)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isAuthenticated)
        .onChange(of: isAuthenticated) { oldValue, newValue in
            print("ContentView - isAuthenticated changed from \(oldValue) to \(newValue)")
        }
    }
}

