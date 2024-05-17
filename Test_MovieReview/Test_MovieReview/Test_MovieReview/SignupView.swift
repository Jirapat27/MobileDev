//
//  SignupView.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SignupView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var userIsLoggedIn = false
    
    var body: some View {
        if userIsLoggedIn {
            MainView()
        } else {
            content
        }
    }
    
    var content: some View {
        NavigationStack{
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 30)
                    
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text("Create an account")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(red: 0.4, green: 0, blue: 0, opacity: 0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onAppear {
                            UITextField.appearance().attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        }
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(red: 0.4, green: 0, blue: 0, opacity: 0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onAppear {
                            UITextField.appearance().attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        }
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(red: 0.4, green: 0, blue: 0, opacity: 0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onAppear {
                            UITextField.appearance().attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        }
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(red: 0.4, green: 0, blue: 0, opacity: 0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onAppear {
                            UITextField.appearance().attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        }
                    
                    Button {
                        Signup()
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .shadow(color: .red, radius: 5, x: 0, y: 2)
                    }
                    
                    HStack {
                        Text("Already have an account? ")
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: LoginView()){
                            Text("Login")
                                .foregroundStyle(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }
                .padding()
            }
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn.toggle()
                    }
                }
            }
        }
    }
        
        func Signup(){
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error signing up: \(error.localizedDescription)")
                    return
                }
                
                // URL ของภาพโปรไฟล์ default
                let defaultProfilePicURL = "https://firebasestorage.googleapis.com/v0/b/mymoviereviewapp-f22be.appspot.com/o/userProfilePic%2Fblank_profile_picture_0.png?alt=media&token=8d4c3c77-b869-4c25-b015-823204add98b"
                
                // สร้างข้อมูลที่จะบันทึกลงใน Firestore
                let userData: [String: Any] = [
                    "username": username,
                    "email": email,
                    "profilePic": defaultProfilePicURL // เพิ่ม URL ของภาพโปรไฟล์ default
                    // คุณสามารถเพิ่มข้อมูลเพิ่มเติมตามต้องการได้
                ]
                
                // เชื่อมต่อ Firestore database
                let db = Firestore.firestore()
                
                // เพิ่มเอกสารใหม่ในคอลเลกชัน "users"
                db.collection("users").addDocument(data: userData) { error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("User signed up successfully!")
                        // เมื่อลงทะเบียนสำเร็จ สามารถทำการอัปเดต state หรือทำสิ่งอื่นตามต้องการได้
                    }
                }
            }
        }
}
