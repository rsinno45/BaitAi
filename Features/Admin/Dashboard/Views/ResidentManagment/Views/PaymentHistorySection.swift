//
//  PaymentHistorySection.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//
import SwiftUI

struct PaymentHistorySection: View {
    let payments: [Payment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Payment History")
            
            ForEach(payments) { payment in
                PaymentRowNew(payment: payment)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct PaymentRowNew: View {
    let payment: Payment
    
    var body: some View {
        Text(payment.type.rawValue)
    }
}
