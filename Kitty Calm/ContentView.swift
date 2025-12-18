//
//  ContentView.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var kittenViewModel = KittenViewModel()
    @State private var showGallery = false
    @State private var showQuiz = false
    @State private var showSettings = false
    private let backgroundColors = ThemeManager.pastelBackgrounds
    
    
    var body: some View {
        NavigationStack {
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
                                    title: "Glasses",
                                    isOn: kittenViewModel.showGlasses
                                ) {
                                    withAnimation {
                                        kittenViewModel.showGlasses.toggle()
                                    }
                                }
                                
                                ToggleButton(
                                    title: "Hat",
                                    isOn: kittenViewModel.showHat
                                ) {
                                    withAnimation {
                                        kittenViewModel.showHat.toggle()
                                    }
                                }
                                
                                ToggleButton(
                                    title: "Collar",
                                    isOn: kittenViewModel.showCollar
                                ) {
                                    withAnimation {
                                        kittenViewModel.showCollar.toggle()
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
            }
            .navigationDestination(isPresented: $showGallery) {
                GalleryView()
            }
            .navigationDestination(isPresented: $showQuiz) {
                QuizView()
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
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

struct BackgroundColorPickerView: View {
    @Binding var selectedColor: Color
    let colors: [(name: String, color: Color)]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Background")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .padding(.top, 40)
                    
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
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                
                                Spacer()
                                
                                if selectedColor == colorOption.color {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.9))
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
                                    .fill(Color(red: 0.75, green: 0.84, blue: 0.96))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
