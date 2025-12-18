import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var kittenViewModel = KittenViewModel()
    @State private var showGallery = false
    @State private var showQuiz = false
    @State private var showSettings = false
    private let backgroundColors = ThemeManager.pastelBackgrounds
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                        
                        ZStack {
                            // Kitten view (centered)
                            KittenView()
                                .environmentObject(kittenViewModel)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                                .zIndex(0)
                        }
                        
                        Spacer()
                        
                        // Bottom controls
                        VStack(spacing: 16) {
                            // Accessories toggles
                            HStack(spacing: 12) {
                                ToggleButton(
                                    title: "Hearts",
                                    isOn: kittenViewModel.showHearts
                                ) {
                                    withAnimation {
                                        kittenViewModel.showHearts.toggle()
                                        if kittenViewModel.showHearts {
                                            kittenViewModel.showStars = false
                                        }
                                    }
                                }
                                
                                ToggleButton(
                                    title: "Stars",
                                    isOn: kittenViewModel.showStars
                                ) {
                                    withAnimation {
                                        kittenViewModel.showStars.toggle()
                                        if kittenViewModel.showStars {
                                            kittenViewModel.showHearts = false
                                        }
                                    }
                                }
                                
                                ToggleButton(
                                    title: "Purring",
                                    isOn: kittenViewModel.isPurring
                                ) {
                                    withAnimation {
                                        kittenViewModel.isPurring.toggle()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Main buttons
                            HStack(spacing: 16) {
                                CustomButton(title: "Quiz") {
                                    showQuiz = true
                                }
                                
                                CustomButton(title: "Gallery") {
                                    showGallery = true
                                }
                                
                                CustomButton(title: "Background") {
                                    showSettings = true
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                
                // Navigation Links (hidden)
                NavigationLink(destination: GalleryView(), isActive: $showGallery) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(destination: QuizView(), isActive: $showQuiz) {
                    EmptyView()
                }
                .hidden()
            }
            .sheet(isPresented: $showSettings) {
                BackgroundColorPickerView(
                    selectedColor: $themeManager.backgroundColor,
                    colors: backgroundColors
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Kitty Calm")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}

struct BackgroundColorPickerView: View {
    @Binding var selectedColor: Color
    let colors: [(name: String, color: Color)]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppConstants.Colors.backgroundBeige
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Background")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .padding(.top, 40)
                        .accessibilityAddTraits(.isHeader)
                    
                    ForEach(colors, id: \.name) { colorOption in
                        Button(action: {
                            selectedColor = colorOption.color
                            dismiss()
                        }) {
                            HStack {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                                
                                Text(colorOption.name)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(AppConstants.Colors.textPrimary)
                                
                                Spacer()
                                
                                if areColorsSimilar(selectedColor, colorOption.color) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppConstants.Colors.checkmarkBlue)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .accessibilityLabel("\(colorOption.name) background color")
                        .accessibilityHint(areColorsSimilar(selectedColor, colorOption.color) ? "Currently selected" : "Tap to select")
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppConstants.Colors.buttonBlue)
                            )
                            .accessibilityLabel("Done")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper function to compare colors more reliably
    private func areColorsSimilar(_ color1: Color, _ color2: Color) -> Bool {
        // Use UIColor comparison which is more reliable than Color
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        uiColor1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        uiColor2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        // Compare with small tolerance for floating point precision
        let tolerance: CGFloat = 0.01
        return abs(red1 - red2) < tolerance &&
               abs(green1 - green2) < tolerance &&
               abs(blue1 - blue2) < tolerance &&
               abs(alpha1 - alpha2) < tolerance
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
