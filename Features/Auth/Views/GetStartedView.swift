//
//  GetStartedView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 11/7/24.
//
import SwiftUI
import Lottie


struct LottieView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        // Load animation from URL
        if let url = URL(string: "https://lottie.host/a004c731-27c3-42d8-bef5-45022047091a/ziWhz76U97.json") {
            LottieAnimation.loadedFrom(url: url) { animation in
                animationView.animation = animation
                animationView.play()
            }
        }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // Constrain the animation view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update view if needed
    }
}

struct GetStartedView: View {
    
    @Binding var isGetStartedShowing: Bool
        @Binding var isAuthenticated: Bool
        @Binding var isAdmin: Bool
    
        // Define colors
        let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
        
        var body: some View {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Lottie Animation
                    LottieView()
                        .frame(width: 300, height: 300)
                    
                    // Title
                    Text("Bait.ai")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Subtitle
                    Text("Manage your properties with ease")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Get Started Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isGetStartedShowing = false
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(goldColor)
                            .cornerRadius(15)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer().frame(height: 50)
                }
            }
        }
    }
