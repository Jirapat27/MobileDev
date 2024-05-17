//
//  Homepage.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//

//import SwiftUI
//import Firebase
//
//struct Movie: Identifiable {
//    let id = UUID()
//    let title: String
//    let imageName: String
//}
//
//struct Homepage: View {
//    let movies: [Movie] = [
//        Movie(title: "Movie 1", imageName: "movie1"),
//        Movie(title: "Movie 2", imageName: "movie2"),
//        Movie(title: "Movie 3", imageName: "movie3"),
//        Movie(title: "Movie 4", imageName: "movie4"),
//        Movie(title: "Movie 5", imageName: "movie5"),
//        Movie(title: "Movie 6", imageName: "movie6"),
//        Movie(title: "Movie 7", imageName: "movie7"),
//        Movie(title: "Movie 8", imageName: "movie8"),
//        // Add more movies as needed
//    ]
//    
//    let gridLayout = [
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//    ]
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVGrid(columns: gridLayout, spacing: 20) {
//                    ForEach(movies) { movie in
//                        NavigationLink(destination: MovieDetail(movie: movie)) {
//                            MovieItem(movie: movie)
//                        }
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Movies")
//        }
//    }
//}
