//
//  BaitAiApp.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/26/24.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct BaitAiApp: App {
    @State private var isAuthenticated = false
    @State private var isAdmin = false
    @State private var isGetStartedShowing = true  // Changed name for clarity
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
   
    var body: some Scene {
        WindowGroup {
            if isGetStartedShowing {
                GetStartedView(
                    isGetStartedShowing: $isGetStartedShowing,
                    isAuthenticated: $isAuthenticated,
                    isAdmin: $isAdmin
                )
            } else {
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
}
