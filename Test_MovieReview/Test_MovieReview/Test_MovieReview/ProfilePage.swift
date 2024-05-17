import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePage: View {

    @State private var isLoggedOut = false
    @State private var userData: UserData?
    @State private var showLoginView = false // เพิ่ม State เพื่อเป็นตัวบอกว่าควรแสดง LoginView หรือไม่

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let profilePicURL = userData?.profilePic,
                       let url = URL(string: profilePicURL),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300) // ปรับขนาดรูปภาพให้เหมาะสม
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300) // ปรับขนาดรูปภาพให้เหมาะสม
                            .foregroundColor(.gray)
                    }
                    
                    Text("Username: \(userData?.username ?? "")")
                        .foregroundColor(.white)
                        .font(.title) // เพิ่มขนาดตัวอักษร
                        .fontWeight(.bold) // เพิ่มความหนาตัวอักษร
                        .padding(.top, 10) // เพิ่ม padding ด้านบนให้ห่างจากรูปโปรไฟล์
                    
                    Button(action: {
                        logout()
                    }) {
                        Text("Logout")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .shadow(color: .red, radius: 5, x: 0, y: 2)
                    }
                }
                .alert(isPresented: $isLoggedOut) {
                    Alert(
                        title: Text("Logged Out"),
                        message: Text("Logged out successfully"),
                        dismissButton: .default(Text("OK")) {
                            redirectToLogin()
                        }
                    )
                }
            }
            .navigationTitle("Profile")
            .fullScreenCover(isPresented: $showLoginView) { // แสดง LoginView เมื่อ showLoginView เป็น true
                LoginView()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            fetchUserData()
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func redirectToLogin() {
        showLoginView = true // เปลี่ยนค่า showLoginView เป็น true เพื่อแสดง LoginView
    }
    
    func fetchUserData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: currentUserEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("User data not found")
                return
            }
            
            // มีข้อมูลผู้ใช้ที่พบ
            let userData = documents[0].data()
            self.userData = UserData(
                username: userData["username"] as? String ?? "",
                profilePic: userData["profilePic"] as? String ?? ""
            )
        }
    }
}

struct UserData {
    let username: String
    let profilePic: String
}
