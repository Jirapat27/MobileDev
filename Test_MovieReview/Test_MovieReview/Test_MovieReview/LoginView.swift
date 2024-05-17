//
//  LoginView.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
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
                
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Please login to your account")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(red: 0.4, green: 0, blue: 0, opacity: 0.5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .onAppear {
                        UITextField.appearance().attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
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
                
                Button {
                    Login()
                } label: {
                    Text("Login")
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
                    Text("Don't have an account? ")
                        .foregroundColor(.white)
                    NavigationLink(destination: SignupView()){
                        Text("Sign Up")
                            .navigationBarBackButtonHidden(true) // 1
                            .foregroundStyle(.blue)
                    }
                    
                }
                .frame(maxWidth: .infinity , alignment: .center)
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
    
    func Login(){
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}

#Preview {
    LoginView()
}

