import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var currentImageIndex: Int = 0
    @State private var imageOpacity: Double = 1.0
    
    // Use mascot images here so quiz reward images are shown only after quiz completion.
    private let imageNames = ["kitten", "shy", "surprised", "sleeping", "waving_hand", "happy", "hello_wave", "waving_hands"]
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title
                Text("Kitten Gallery")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .padding(.top, 20)
                
                Spacer()
                
                // Image container
                ZStack {
                    Image(imageNames[currentImageIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 360)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .opacity(imageOpacity)
                }
                
                Spacer()
                
                // Custom button
                CustomButton(
                    title: "Show Another Kitten",
                    action: {
                        showNextImage()
                    }
                )
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func showNextImage() {
        withAnimation(.easeOut(duration: 0.3)) {
            imageOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentImageIndex = (currentImageIndex + 1) % imageNames.count
            
            withAnimation(.easeIn(duration: 0.3)) {
                imageOpacity = 1.0
            }
        }
    }
}
