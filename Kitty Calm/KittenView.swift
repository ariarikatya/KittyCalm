//
//  KittenView.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct KittenView: View {
    @EnvironmentObject var viewModel: KittenViewModel
    @State private var baseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var currentPose: MascotPose = .seated
    @State private var isAnimating: Bool = false
    @State private var lastAnimation: AnimationKind = .none
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            let kittenHeight = min(geometry.size.height * 0.6, 360)
            
            ZStack(alignment: .top) {

                Image(currentPose.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: kittenHeight * currentPose.baseHeightMultiplier)
                    .scaleEffect(baseScale)
                    .rotationEffect(.degrees(rotation))

                if viewModel.showThoughtBubble {
                    ThoughtBubble(text: viewModel.currentThought)
                        .offset(y: -kittenHeight * 0.55)
                        .transition(.scale.combined(with: .opacity))
                }
                
                accessoriesView
                    .frame(height: kittenHeight)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture(count: 2)
                    .onEnded { handleDoubleTap() }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { handleSingleTap() }
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: true)
                ) {
                    baseScale = 1.03
                }
            }
        }
    }
    
    // MARK: - Accessories View (overlays, not part of mascot drawing)
    private var accessoriesView: some View {
        ZStack {
            if viewModel.showGlasses {
                Image("glasses_overlay")
                    .resizable()
                    .scaledToFit()
            }
            
            if viewModel.showHat {
                Image("hat_overlay")
                    .resizable()
                    .scaledToFit()
                    .offset(y: -40)
            }
            
            if viewModel.showCollar {
                Image("collar_overlay")
                    .resizable()
                    .scaledToFit()
                    .offset(y: 40)
            }
        }
        .allowsHitTesting(false)
    }
    
    
    // MARK: - Gesture Handlers (exactly one animation per tap)
    func handleSingleTap() {
        runAnimation(kind: .singleTap, duration: 0.35) {
            currentPose = .shy
            baseScale = 1.04
        } reset: {
            currentPose = .seated
            baseScale = 1.0
            rotation = 0
        }
        
        viewModel.showThought()
    }
    
    func handleDoubleTap() {
        runAnimation(kind: .doubleTap, duration: 0.4) {
            currentPose = .wavingHands
            rotation = 6
        } reset: {
            currentPose = .seated
            baseScale = 1.0
            rotation = 0
        }
        
        viewModel.showThought()
    }
    
    private func runAnimation(kind: AnimationKind, duration: Double, changes: @escaping () -> Void, reset: @escaping () -> Void) {
        guard !isAnimating else { return }
        isAnimating = true
        lastAnimation = kind
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            changes()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                reset()
            }
            isAnimating = false
        }
    }
}

// MARK: - Mascot Pose
private enum MascotPose {
    case seated
    case shy
    case surprised
    case sleeping
    case wavingHand
    case happy
    case helloWave
    case wavingHands
    
    var imageName: String {
        switch self {
        case .seated:
            return "kitten"
        case .shy:
            return "shy"
        case .surprised:
            return "surprised"
        case .sleeping:
            return "sleeping"
        case .wavingHand:
            return "waving_hand"
        case .happy:
            return "happy"
        case .helloWave:
            return "hello_wave"
        case .wavingHands:
            return "waving_hands"
        }
    }
    
    // Adjusts relative visual size without changing asset files
    var baseHeightMultiplier: CGFloat {
        switch self {
        case .seated:
            return 1.12
        default:
            return 1.0
        }
    }
    
    var baseScale: CGFloat {
        switch self {
        case .seated:
            return 1.02
        default:
            return 1.0
        }
    }
}

private enum AnimationKind {
    case none
    case singleTap
    case doubleTap
}
