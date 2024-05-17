//
//  Test_MovieReviewApp.swift
//  Test_MovieReview
//
//  Created by jira on 13/5/2567 BE.
//


import SwiftUI
import Firebase

@main
struct Test_MovieReviewApp: App {
    
    init() {
        FirebaseApp.configure()
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some Scene {
        WindowGroup {
            LandingPage()
        }
    }
}
