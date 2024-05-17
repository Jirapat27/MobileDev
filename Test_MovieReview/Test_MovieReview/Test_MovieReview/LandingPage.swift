import SwiftUI
import FirebaseAuth

struct LandingPage: View {
    @State private var isMovieViewListPresented = false

    var body: some View {
        Group {
            if Auth.auth().currentUser != nil {
                // Redirect to MovieViewList if user is logged in
                MainView()
            } else {
                // Show LandingPage if user is not logged in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        Text("Movie Diary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Capture your great memories in your own way")
                            .font(.caption)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        Spacer()
                        Button(action: {
                            isMovieViewListPresented = true
                        }) {
                            Text("Get started")
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
                }
                .fullScreenCover(isPresented: $isMovieViewListPresented) {
                    LoginView()
                }
            }
        }
    }
}
