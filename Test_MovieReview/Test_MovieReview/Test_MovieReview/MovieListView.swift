import SwiftUI
import Firebase
import FirebaseFirestore

struct Movie: Identifiable {
    let id = UUID()
    let name: String
    let desc: String
    let genre: [String]
    let imageURL: String
}

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    
    init() {
        fetchMovies()
    }
    
    func fetchMovies() {
        let db = Firestore.firestore()
        db.collection("movies").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.movies = documents.map { document in
                let data = document.data()
                let name = data["movieName"] as? String ?? ""
                let desc = data["movieDesc"] as? String ?? ""
                let genre = data["movieGenre"] as? [String] ?? []
                let imageURL = data["movieImage"] as? String ?? ""
                return Movie(name: name, desc: desc, genre: genre, imageURL: imageURL)
            }
        }
    }
}

struct MovieListView: View {
    @ObservedObject var viewModel = MovieViewModel()
    
    @State private var isNavBarHidden = false
    @State private var isAddMoviePagePresented = false // เพิ่ม State สำหรับตรวจสอบการเปิดหน้า AddMoviePage
    
    let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(viewModel.movies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                VStack {
                                    if let url = URL(string: movie.imageURL),
                                       let imageData = try? Data(contentsOf: url),
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(20)
                                            .padding(.bottom, 15)
                                    }
                                    Text(movie.name)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom))
                
                // เพิ่ม NavigationLink เพื่อเปิดหน้า AddMoviePage
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddMoviePage(), isActive: $isAddMoviePagePresented) {
                            Image(systemName: "plus.circle.fill") // ใช้ไอคอนรูปบวก
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .onPreferenceChange(OffsetPreferenceKey.self) { offset in
                withAnimation {
                    isNavBarHidden = offset > 0
                }
            }
            .navigationBarHidden(isNavBarHidden)
            .background(isNavBarHidden ? Color(red: 0.2, green: 0, blue: 0) : nil)
            .onAppear {
                self.isAddMoviePagePresented = false // ตั้งค่าให้หน้า AddMoviePage ไม่ถูกเปิดเมื่อหน้านี้ปรากฏขึ้น
            }
        }
    }
}



struct ContentView: View {
    var body: some View {
        MovieListView()
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
