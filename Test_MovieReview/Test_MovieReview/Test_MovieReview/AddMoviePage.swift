//
//  AddMoviePage.swift
//  Test_MovieReview
//
//  Created by jira on 14/5/2567 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct AddMoviePage: View {
    @State private var movieName = ""
    @State private var movieDescription = ""
    @State private var genre1 = ""
    @State private var genre2 = ""
    @State private var genre3 = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isAddMoviePagePresented = false // เพิ่ม State เพื่อตรวจสอบการเปิดหน้า AddMoviePage

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Form {
                    Section(header: Text("Movie Information")) {
                        TextField("Name", text: $movieName)
                        TextField("Description", text: $movieDescription)
                        HStack {
                            TextField("Genre 1", text: $genre1)
                            TextField("Genre 2", text: $genre2)
                            TextField("Genre 3", text: $genre3)
                        }
                    }
                    
                    Section(header: Text("Upload Image")) {
                        Button(action: {
                            self.isImagePickerPresented = true
                        }) {
                            Text("Select Image")
                        }
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            addMovie()
                        }) {
                            Text("Add Movie")
                        }
                    }
                }
                .navigationBarTitle("Add Movie")
                .navigationBarItems(trailing: Button("Cancel") { // ปุ่ม "Cancel" สำหรับยกเลิกการเพิ่มภาพยนตร์
                    self.isAddMoviePagePresented = false
                })
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $isImagePickerPresented) {
            CustomImagePicker(selectedImage: $selectedImage)
        }
    }
    
    func addMovie() {
        guard let image = selectedImage else {
            print("No image selected")
            return
        }
        
        // Upload image to Firestore Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("movieImages/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let _ = imageRef.putData(imageData, metadata: nil) { metadata, error in
                guard let _ = metadata else {
                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Image uploaded successfully, now get download URL
                imageRef.downloadURL { url, error in
                    guard let imageURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Create movie object with data
                    let movieData: [String: Any] = [
                        "movieName": movieName,
                        "movieDesc": movieDescription,
                        "movieGenre": [genre1, genre2, genre3],
                        "movieImage": imageURL.absoluteString
                    ]
                    
                    // Add movie data to Firestore
                    let db = Firestore.firestore()
                    db.collection("movies").addDocument(data: movieData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Movie added successfully")
                            // Clear fields after adding movie
                            movieName = ""
                            movieDescription = ""
                            genre1 = ""
                            genre2 = ""
                            genre3 = ""
                            selectedImage = nil
                            self.isAddMoviePagePresented = false // ปิดหน้า AddMoviePage หลังจากเพิ่มภาพยนตร์เสร็จ
                        }
                    }
                }
            }
        }
    }
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CustomImagePicker

        init(parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
