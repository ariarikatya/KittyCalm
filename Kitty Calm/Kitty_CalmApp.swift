import SwiftUI

@main
struct Kitty_CalmApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(themeManager)
                .preferredColorScheme(.light)
        }
    }
}
