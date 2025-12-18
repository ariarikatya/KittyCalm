import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var currentImageIndex: Int = 0
    @State private var imageOpacity: Double = 1.0
    @State private var imageChangeTask: Task<Void, Never>?
    
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
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)
                
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
                    .accessibilityLabel("Kitten image \(currentImageIndex + 1) of \(imageNames.count)")
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
        .onDisappear {
            imageChangeTask?.cancel()
        }
    }
    
    private func showNextImage() {
        imageChangeTask?.cancel()
        
        withAnimation(.easeOut(duration: AppConstants.AnimationDuration.medium)) {
            imageOpacity = 0
        }
        
        imageChangeTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.medium * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            currentImageIndex = (currentImageIndex + 1) % imageNames.count
            
            withAnimation(.easeIn(duration: AppConstants.AnimationDuration.medium)) {
                imageOpacity = 1.0
            }
        }
    }
}
