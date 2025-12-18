//
//  KittenView.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI
import AVFoundation
import UIKit

enum MascotAnimationState {
    case idle
    case interacting
    case purring
}

struct KittenView: View {

    @EnvironmentObject var viewModel: KittenViewModel

    // MARK: - Visual state
    @State private var currentPose: MascotPose = .seated
    @State private var baseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var animationState: MascotAnimationState = .idle

    // MARK: - Interaction state
    @State private var isAnimating = false
    @State private var isPetting = false

    // MARK: - Audio & Haptics
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    @State private var purrPlayer: AVAudioPlayer?

    // MARK: - Tasks
    @State private var blinkTask: Task<Void, Never>?

    // MARK: - Random tap poses
    private let tapPoses: [MascotPose] = [
        .shy,
        .happy,
        .surprised,
        .wavingHand,
        .helloWave,
        .sleeping,
        .wavingHands
    ]

    var body: some View {
        GeometryReader { geometry in
            let kittenHeight = min(geometry.size.height * 0.6, 360)

            ZStack {

                Image(viewModel.isPurring ? "purring" : currentPose.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: kittenHeight * currentPose.heightMultiplier)
                                    .scaleEffect(baseScale)
                                    .rotationEffect(.degrees(rotation))

                                // MARK: - Accessories - убираем этот блок
                                
                                // MARK: - Hearts effect
                                if viewModel.showHearts {
                                    HeartsEffect()
                                }
                                
                                // MARK: - Stars effect
                                if viewModel.showStars {
                                    StarsEffect()
                                }

                                // MARK: - Thought bubble
                                if viewModel.showThoughtBubble {
                                    ThoughtBubble(text: viewModel.currentThought)
                                        .offset(y: -kittenHeight * 0.75)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())

                            // MARK: - Tap (random animation или возврат из purring)
                            .onTapGesture {
                                if viewModel.isPurring {
                                    viewModel.isPurring = false
                                    stopPurring()
                                } else {
                                    handleTap()
                                }
                            }

            // MARK: - Petting (drag = purr)
                            .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { _ in
                                                    if animationState != .purring {
                                                        animationState = .purring
                                                        startPurring()
                                                        haptic.impactOccurred()
                                                    }
                                                }

                                                .onEnded { _ in
                                                    if !viewModel.isPurring {
                                                        stopPurring()
                                                    }
                                                    isPetting = false
                                                }
                                        )

                                        // MARK: - Idle animations
                                        .onAppear {
                                            startBreathing()
                                            // убираем startTailWag()
                                            startBlinking()
                                        }
                                        .onDisappear {
                                            blinkTask?.cancel()
                                        }
                                        .onChange(of: viewModel.isPurring) { _, newValue in
                                            if newValue {
                                                animationState = .purring
                                                startPurring()
                                            } else {
                                                animationState = .idle
                                                stopPurring()
                                            }
                                        }
                                    }
                                }

                                // Убираем accessoriesView

                                // MARK: - Tap animation
    private func handleTap() {
        guard animationState == .idle else { return }

        animationState = .interacting

        let randomPose = tapPoses.randomElement() ?? .shy

        withAnimation(.spring(response: 1.0, dampingFraction: 0.65)) {
            currentPose = randomPose
            baseScale = 1.08
            rotation = Double.random(in: -6...6)
        }

        viewModel.showThought()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring()) {
                currentPose = .seated
                baseScale = 1.0
                rotation = 0
            }

            animationState = .idle
        }
    }


                                // MARK: - Breathing
    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: 2.8)
                .repeatForever(autoreverses: true)
        ) {
            if animationState == .idle {
                baseScale = 1.03
            }
        }
    }
                                // MARK: - Blinking
    private func startBlinking() {
        blinkTask?.cancel()

        blinkTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: UInt64.random(in: 4_000_000_000...8_000_000_000)
                )

                guard animationState == .idle else { continue }

                await MainActor.run {
                    currentPose = .blink
                }

                try? await Task.sleep(nanoseconds: 220_000_000)

                await MainActor.run {
                    currentPose = .seated
                }
            }
        }
    }


                                // MARK: - Purring
    // MARK: - Purring
    private func startPurring() {
        guard let url = Bundle.main.url(forResource: "purr", withExtension: "mp3") else {
            print("❌ Purr sound file not found!")
            return
        }
        
        do {
            // Настроим аудио сессию
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            purrPlayer = try AVAudioPlayer(contentsOf: url)
            purrPlayer?.numberOfLoops = -1
            purrPlayer?.volume = 0.5  // Увеличил громкость с 0.35 до 0.5
            purrPlayer?.prepareToPlay()
            purrPlayer?.play()
            
            print("✅ Purr sound started playing")
        } catch {
            print("❌ Error playing purr sound: \(error.localizedDescription)")
        }
    }

    private func stopPurring() {
        purrPlayer?.stop()
        purrPlayer = nil
        print("⏹️ Purr sound stopped")
    }
                            }

                            // MARK: - Hearts Effect
                            struct HeartsEffect: View {
                                @State private var hearts: [HeartParticle] = []
                                
                                var body: some View {
                                    ZStack {
                                        ForEach(hearts) { heart in
                                            Text("❤️")
                                                .font(.system(size: heart.size))
                                                .offset(x: heart.x, y: heart.y)
                                                .opacity(heart.opacity)
                                                .scaleEffect(heart.scale)
                                        }
                                    }
                                    .onAppear {
                                        startHeartAnimation()
                                    }
                                }
                                
                                private func startHeartAnimation() {
                                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                                        let newHeart = HeartParticle(
                                            x: CGFloat.random(in: -120...120),
                                            y: CGFloat.random(in: -150...150),
                                            size: CGFloat.random(in: 20...40)
                                        )
                                        hearts.append(newHeart)
                                        
                                        withAnimation(.easeOut(duration: 2.0)) {
                                            if let index = hearts.firstIndex(where: { $0.id == newHeart.id }) {
                                                hearts[index].opacity = 0
                                                hearts[index].y -= 50
                                                hearts[index].scale = 1.5
                                            }
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            hearts.removeAll { $0.id == newHeart.id }
                                        }
                                        
                                        if hearts.isEmpty {
                                            timer.invalidate()
                                        }
                                    }
                                }
                            }

                            struct HeartParticle: Identifiable {
                                let id = UUID()
                                var x: CGFloat
                                var y: CGFloat
                                let size: CGFloat
                                var opacity: Double = 1.0
                                var scale: CGFloat = 1.0
                            }

                            // MARK: - Stars Effect
                            struct StarsEffect: View {
                                @State private var stars: [StarParticle] = []
                                
                                var body: some View {
                                    ZStack {
                                        ForEach(stars) { star in
                                            Text("⭐")
                                                .font(.system(size: star.size))
                                                .offset(x: star.x, y: star.y)
                                                .opacity(star.opacity)
                                                .rotationEffect(.degrees(star.rotation))
                                                .scaleEffect(star.scale)
                                        }
                                    }
                                    .onAppear {
                                        startStarAnimation()
                                    }
                                }
                                
                                private func startStarAnimation() {
                                    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
                                        let newStar = StarParticle(
                                            x: CGFloat.random(in: -120...120),
                                            y: CGFloat.random(in: -150...150),
                                            size: CGFloat.random(in: 18...35)
                                        )
                                        stars.append(newStar)
                                        
                                        withAnimation(.easeInOut(duration: 1.8)) {
                                            if let index = stars.firstIndex(where: { $0.id == newStar.id }) {
                                                stars[index].opacity = 0
                                                stars[index].rotation = 360
                                                stars[index].scale = 0.3
                                            }
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                            stars.removeAll { $0.id == newStar.id }
                                        }
                                        
                                        if stars.isEmpty {
                                            timer.invalidate()
                                        }
                                    }
                                }
                            }

                            struct StarParticle: Identifiable {
                                let id = UUID()
                                var x: CGFloat
                                var y: CGFloat
                                let size: CGFloat
                                var opacity: Double = 1.0
                                var rotation: Double = 0
                                var scale: CGFloat = 1.0
                            }
