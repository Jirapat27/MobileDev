import SwiftUI

struct MainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Adjust the red color's opacity to be slightly translucent but mostly opaque
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.9) // Adjust this value as needed
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView {
            MovieListView()
                .tabItem {
                    Label("Home", systemImage: "movieclapper.fill")
                }
            SearchPage()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(Color.red.opacity(1.0))
    }
}
