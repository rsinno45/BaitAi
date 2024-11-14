//
//  DocumentUploader.swift
//  BaitAi
//
//  Created by Rakan Sinno on 10/29/24.
//

import SwiftUI

struct DocumentUploader: View {
    @State private var isShowingDocumentPicker = false
    @State private var isUploading = false
    @Binding var uploadedDocumentURL: String?
    let goldColor = Color(red: 212/255, green: 175/255, blue: 55/255)
    
    var body: some View {
        VStack {
            if isUploading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: goldColor))
            } else if let url = uploadedDocumentURL {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(goldColor)
                    Text("Document Uploaded")
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        uploadedDocumentURL = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            } else {
                Button(action: {
                    isShowingDocumentPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Upload Document")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(goldColor)
                    .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $isShowingDocumentPicker) {
            // Note: This is a placeholder for document picker functionality
            // You'll need to implement proper document picking and uploading
            DocumentPicker(uploadedDocumentURL: $uploadedDocumentURL)
        }
    }
}

// Helper view for document picking
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var uploadedDocumentURL: String?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text, .image])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Here you would typically upload the document to Firebase Storage
            // and then set the downloadURL to uploadedDocumentURL
            // For now, we'll just set the local file path
            parent.uploadedDocumentURL = url.path
        }
    }
}
