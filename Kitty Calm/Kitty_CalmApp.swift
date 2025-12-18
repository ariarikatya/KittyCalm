//
//  Kitty_CalmApp.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI

@main
struct Kitty_CalmApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(.light)
        }
    }
}
