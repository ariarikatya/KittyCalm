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

    // MARK: - Visual state
    @State private var currentPose: MascotPose = .seated
    @State private var baseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var tailAngle: Double = 0

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

                // MARK: - Tail (behind kitten)
                Image("tail_idle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: kittenHeight * 0.4)
                    .offset(x: 40, y: kittenHeight * 0.25)
                    .rotationEffect(.degrees(tailAngle), anchor: .bottom)

                // MARK: - Kitten
                Image(currentPose.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: kittenHeight * currentPose.heightMultiplier)
                    .scaleEffect(baseScale)
                    .rotationEffect(.degrees(rotation))

                // MARK: - Accessories
                accessoriesView

                // MARK: - Thought bubble
                if viewModel.showThoughtBubble {
                    ThoughtBubble(text: viewModel.currentThought)
                        .offset(y: -kittenHeight * 0.75)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())

            // MARK: - Tap (random animation)
            .onTapGesture {
                handleTap()
            }

            // MARK: - Petting (drag = purr)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPetting {
                            isPetting = true
                            startPurring()
                            haptic.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        stopPurring()
                        isPetting = false
                    }
            )

            // MARK: - Idle animations
            .onAppear {
                startBreathing()
                startTailWag()
                startBlinking()
            }
            .onDisappear {
                blinkTask?.cancel()
            }
        }
    }

    // MARK: - Accessories View
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

    // MARK: - Tap animation
    private func handleTap() {
        guard !isAnimating else { return }
        isAnimating = true

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
            isAnimating = false
        }
    }

    // MARK: - Breathing
    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: 2.8)
                .repeatForever(autoreverses: true)
        ) {
            baseScale = 1.03
        }
    }

    // MARK: - Tail wag
    private func startTailWag() {
        withAnimation(
            .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
        ) {
            tailAngle = 12
        }
    }

    // MARK: - Blinking
    private func startBlinking() {
        blinkTask?.cancel()

        blinkTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: UInt64.random(in: 3_000_000_000...6_000_000_000)
                )

                guard !isAnimating else { continue }

                await MainActor.run {
                    currentPose = .blink
                }

                try? await Task.sleep(nanoseconds: 160_000_000)

                await MainActor.run {
                    currentPose = .seated
                }
            }
        }
    }

    // MARK: - Purring
    private func startPurring() {
        guard let url = Bundle.main.url(forResource: "purr", withExtension: "mp3") else { return }

        purrPlayer = try? AVAudioPlayer(contentsOf: url)
        purrPlayer?.numberOfLoops = -1
        purrPlayer?.volume = 0.35
        purrPlayer?.play()
    }

    private func stopPurring() {
        purrPlayer?.stop()
        purrPlayer = nil
    }
}
