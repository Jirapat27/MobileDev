//
//  SearchBar.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//
//
//import SwiftUI
//
//struct SearchBar: View {
//    @Binding var text: String
//    
//    var body: some View {
//        HStack {
//            TextField("Search", text: $text)
//                .padding(7)
//                .padding(.horizontal, 25)
//                .background(Color(.systemGray6))
//                .cornerRadius(8)
//                .padding(.horizontal, 10)
//                .onTapGesture {
//                    // Hide keyboard
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }
//            Button(action: {
//                // Clear the text
//                self.text = ""
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(.trailing, 10)
//            }
//        }
//    }
//}
