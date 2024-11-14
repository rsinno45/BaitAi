//
//  EditResidentView.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//
import SwiftUI
import Firebase

struct EditResidentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ResidentDetailViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var unitNumber: String = ""
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Unit Number", text: $unitNumber)
                }
            }
            .navigationTitle("Edit Resident")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    // Save logic here
                    dismiss()
                }
                .foregroundColor(goldColor)
            )
        }
    }
}
