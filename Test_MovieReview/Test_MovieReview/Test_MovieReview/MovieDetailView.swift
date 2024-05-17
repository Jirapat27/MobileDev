import SwiftUI
import Firebase
import FirebaseFirestore

struct Comment: Identifiable {
    let id = UUID()
    let movieName: String
    let rating: Int
    let text: String
    let timestamp: Timestamp
    let username: String
    var profilePic: String?
}

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    let movieName: String
    
    init(movieName: String) {
        self.movieName = movieName
        fetchComments()
    }
    
    func fetchComments() {
        let db = Firestore.firestore()
        db.collection("comments")
            .whereField("movieName", isEqualTo: movieName)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching comments: \(error!)")
                    return
                }
                
                var fetchedComments: [Comment] = []
                
                let dispatchGroup = DispatchGroup()
                
                for document in documents {
                    let data = document.data()
                    let movieName = data["movieName"] as? String ?? ""
                    let rating = data["rating"] as? Int ?? 0
                    let text = data["text"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    let username = data["username"] as? String ?? "Anonymous"
                    
                    dispatchGroup.enter()
                    
                    db.collection("users")
                        .whereField("username", isEqualTo: username)
                        .getDocuments { userSnapshot, userError in
                            if let userDocument = userSnapshot?.documents.first {
                                let userData = userDocument.data()
                                let profilePic = userData["profilePic"] as? String
                                let comment = Comment(movieName: movieName, rating: rating, text: text, timestamp: timestamp, username: username, profilePic: profilePic)
                                fetchedComments.append(comment)
                            } else {
                                let comment = Comment(movieName: movieName, rating: rating, text: text, timestamp: timestamp, username: username, profilePic: nil)
                                fetchedComments.append(comment)
                            }
                            dispatchGroup.leave()
                        }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.comments = fetchedComments
                }
            }
    }
}

struct MovieDetailView: View {
    @State private var commentText = ""
    @State private var selectedRating = 1
    @State private var shouldRefresh = false
    let movie: Movie
    @ObservedObject var commentViewModel: CommentViewModel
    
    init(movie: Movie) {
        self.movie = movie
        self.commentViewModel = CommentViewModel(movieName: movie.name)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    if let url = URL(string: movie.imageURL),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    HStack {
                        ForEach(movie.genre, id: \.self) { genre in
                            Text(genre)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Text(movie.desc)
                        .foregroundColor(.white)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Comments")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.top)
                        
                        if commentViewModel.comments.isEmpty {
                            Text("No comments available")
                                .foregroundColor(.black)
                                .background(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the leading edge
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 10) {
                                    ForEach(commentViewModel.comments.sorted(by: { $0.timestamp.seconds > $1.timestamp.seconds })) { comment in
                                        HStack(spacing: 10) {
                                            if let profilePicURL = comment.profilePic,
                                               let url = URL(string: profilePicURL),
                                               let imageData = try? Data(contentsOf: url),
                                               let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .padding(.bottom, 5)
                                            } else {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.gray)
                                                    .padding(.bottom, 5)
                                            }
                                            VStack(alignment: .leading) {
                                                Text("\(comment.username)")
                                                    .font(.body)
                                                    .foregroundColor(.black)
                                                
                                                VStack {
                                                    Text("Score: \(comment.rating) / 5")
                                                        .font(.caption)
                                                        .foregroundColor(.black)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    Spacer()
                                                    Text("'\(comment.text)'")
                                                        .font(.caption)
                                                        .foregroundColor(.black)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                }
                                            }
                                            Spacer() // Add Spacer to center the username within the comment box
                                        }
                                        .padding()
                                        .background(Color.white.opacity(1.0))
                                        .cornerRadius(10)
                                    }

                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Align HStack to the leading edge
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: shouldRefresh) { _ in
                        self.commentViewModel.fetchComments()
                    }
                    
                    Spacer()
                        
                    VStack(alignment: .leading, spacing: 10) {
                            Text("Add Comment")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                        TextField("Enter your comment", text: $commentText)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(1.0))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        Picker("Rating", selection: $selectedRating) {
                            ForEach(1...5, id: \.self) { rating in
                                Text("\(rating)")
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                            
                        Button("Submit") {
                            let db = Firestore.firestore()
                            db.collection("comments").addDocument(data: [
                                "movieName": movie.name,
                                "rating": selectedRating,
                                "text": commentText,
                                "timestamp": Timestamp(),
                                "username": "Anonymous"
                            ]) { error in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                } else {
                                    print("Document added successfully!")
                                    commentText = ""
                                    selectedRating = 1
                                    shouldRefresh.toggle()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.bottom)
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(Text(movie.name))
            }
        }
    }
}
