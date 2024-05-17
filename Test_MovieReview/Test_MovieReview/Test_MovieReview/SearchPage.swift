//
//  SearchPage.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct SearchPage: View {
    @State private var searchText = ""
    @ObservedObject private var searchViewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    CustomSearchBar(text: $searchText, onSearch: {
                        searchViewModel.searchMovies(with: searchText)
                    })
                        .padding(.top, 10)
                    Text("Search movie : \(searchText)")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    if searchViewModel.movies.isEmpty {
                        Text(searchViewModel.searchResult)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    } else {
                        // ในฟังก์ชัน body ของ SearchPage
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(searchViewModel.movies) { movie in
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
                                }
                            }
                            .padding()
                        }

                    }
                    Spacer()
                }
                .foregroundColor(.white)
            }
            .navigationTitle("Search")
        }
    }
}

class SearchViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResult = ""

    func searchMovies(with searchText: String) {
        guard searchText.count >= 3 else {
            searchResult = "Please enter at least 3 characters"
            movies = []
            return
        }

        let db = Firestore.firestore()
        db.collection("movies")
            .getDocuments { [self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    self.searchResult = "No movie found"
                    self.movies = []
                } else {
                    if let documents = snapshot?.documents {
                        let filteredResults = documents.filter { doc in
                            let movieName = doc.get("movieName") as? String ?? ""
                            return movieName.lowercased().contains(searchText.lowercased())
                        }
                        let results = filteredResults.compactMap { doc -> Movie? in
                            let data = doc.data()
                            let name = data["movieName"] as? String ?? ""
                            let desc = data["movieDesc"] as? String ?? ""
                            let genre = data["movieGenre"] as? [String] ?? []
                            let imageURL = data["movieImage"] as? String ?? ""
                            return levenshtein(aStr: name.lowercased(), bStr: searchText.lowercased()) <= 5 ? Movie(name: name, desc: desc, genre: genre, imageURL: imageURL) : nil
                        }
                        if results.isEmpty {
                            print("No movie found")
                            self.searchResult = "No movie found"
                            self.movies = []
                        } else {
                            self.movies = results
                            self.searchResult = ""
                            print("Movies found: \(results.map { $0.name }.joined(separator: ", "))")
                        }
                    } else {
                        print("No movie found")
                        self.searchResult = "No movie found"
                        self.movies = []
                    }
                }
            }
    }

    private func levenshtein(aStr: String, bStr: String) -> Int {
        let a = Array(aStr)
        let b = Array(bStr)
        var dist = [[Int]]()
        
        for i in 0...a.count {
            dist.append([Int](repeating: 0, count: b.count + 1))
        }
        
        for i in 1...a.count {
            dist[i][0] = i
        }
        
        for j in 1...b.count {
            dist[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }
        
        return dist[a.count][b.count]
    }
}

struct CustomSearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Search", text: $text, onCommit: onSearch)
                .foregroundColor(.black)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
}
