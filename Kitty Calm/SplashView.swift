import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.0
    @State private var isActive = false
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                
                themeManager.backgroundColor
                    .ignoresSafeArea()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .onAppear {
                animateLogo()
                proceedToApp()
            }
        }
    }

    private func animateLogo() {
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }

       
        withAnimation(
            .easeInOut(duration: 2.6)
            .repeatForever(autoreverses: true)
        ) {
            scale = 1.03
        }
    }

    private func proceedToApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isActive = true
            }
        }
    }
}

