import SwiftUI

struct PayRentView: View {
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    let lightGoldColor = Color(red: 232/255, green: 205/255, blue: 85/255)
    @Binding var isShowingPayRentView: Bool
    
    
    @State private var selectedPaymentMethod = 0
    @State private var showingPaymentConfirmation = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Rent Payment")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Due in 5 days")
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Amount Due Card
                    VStack(spacing: 15) {
                        Text("Amount Due")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("$1,250.00")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(goldColor)
                        
                        Text("Due Date: October 1, 2024")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Payment Breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Payment Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            PaymentRow(title: "Base Rent", amount: "$1,200.00")
                            PaymentRow(title: "Pet Rent", amount: "$50.00")
                            PaymentRow(title: "Total Due", amount: "$1,250.00", isTotal: true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Payment Method Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Payment Method")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<3) { index in
                                PaymentMethodButton(
                                    isSelected: selectedPaymentMethod == index,
                                    icon: paymentIcons[index],
                                    title: paymentTitles[index],
                                    subtitle: paymentSubtitles[index]
                                ) {
                                    selectedPaymentMethod = index
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Pay Button
                    Button(action: {
                        showingPaymentConfirmation = true
                    }) {
                        Text("Pay Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(goldColor)
                            .cornerRadius(12)
                            .shadow(color: goldColor.opacity(0.3), radius: 5, y: 3)
                    }
                    .padding(.horizontal)
                    .alert("Confirm Payment", isPresented: $showingPaymentConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Confirm") {
                            // Handle payment confirmation
                        }
                    } message: {
                        Text("Would you like to proceed with the payment of $1,250.00?")
                    }
                }
                .padding(.bottom)
                Button(action: {
                    isShowingPayRentView = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(goldColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: goldColor.opacity(0.3), radius: 5, y: 3)
                }
                .padding(.horizontal)

            }
        }
    }
    
    let paymentIcons = ["creditcard.fill", "building.columns.fill", "arrow.right.circle.fill"]
    let paymentTitles = ["Credit Card", "Bank Account", "Quick Pay"]
    let paymentSubtitles = ["Visa ending in 4242", "Account ending in 8790", "Instant transfer"]
}

struct PaymentRow: View {
    let title: String
    let amount: String
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(isTotal ? .semibold : .regular)
            Spacer()
            Text(amount)
                .fontWeight(isTotal ? .semibold : .regular)
        }
        .padding(.vertical, 4)
        if isTotal {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2))
        }
    }
}

struct PaymentMethodButton: View {
    let isSelected: Bool
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : goldColor)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? goldColor : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? goldColor : .gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}


