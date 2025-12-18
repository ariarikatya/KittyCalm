import SwiftUI
import AVFoundation
import UIKit

enum MascotAnimationState: Equatable {
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

// MARK: - Audio & Haptics
private let haptic = UIImpactFeedbackGenerator(style: .soft)
@State private var purrPlayer: AVAudioPlayer?
@State private var audioInterruptionObserver: NSObjectProtocol?

// MARK: - Tasks
@State private var blinkTask: Task<Void, Never>?
@State private var tapAnimationTask: Task<Void, Never>?

private let tapPoses: [MascotPose] = [
    .shy, .happy, .surprised, .wavingHand,
    .helloWave, .sleeping, .wavingHands
]

var body: some View {
    GeometryReader { geometry in
        let kittenHeight = min(geometry.size.height * AppConstants.Layout.kittenHeightMultiplier, AppConstants.Layout.kittenMaxHeight)
        
        ZStack {
            Image(viewModel.isPurring ? "purring" : currentPose.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: kittenHeight * currentPose.heightMultiplier)
                .scaleEffect(baseScale)
                .rotationEffect(.degrees(rotation))
                .accessibilityLabel(viewModel.isPurring ? "Kitten purring" : "Kitten \(currentPose.imageName)")
            
            if viewModel.showHearts {
                HeartsEffect()
            }
            
            if viewModel.showStars {
                StarsEffect()
            }
            
            if viewModel.showThoughtBubble {
                ThoughtBubble(text: viewModel.currentThought)
                    .offset(y: -kittenHeight * AppConstants.Layout.thoughtBubbleOffset)
                    .transition(.opacity.combined(with: .scale))
                    .accessibilityLabel("Kitten thought: \(viewModel.currentThought)")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap to interact with the kitten")
        .onTapGesture {
            if viewModel.isPurring {
                viewModel.isPurring = false
                stopPurring()
                animationState = .idle
            } else if animationState == .purring {
                stopPurring()
                animationState = .idle
            } else {
                handleTap()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if animationState != .purring && !viewModel.isPurring {
                        animationState = .purring
                        startPurring()
                        haptic.impactOccurred()
                    }
                }
                .onEnded { _ in
                    if !viewModel.isPurring {
                        stopPurring()
                        animationState = .idle
                    }
                }
        )
        .onAppear {
            setupAudioSession()
            haptic.prepare()
            startBlinking()
        }
        .onDisappear {
            cleanup()
        }
        .onChange(of: viewModel.isPurring) { newValue in
            if newValue {
                if animationState != .purring {
                    animationState = .purring
                    startPurring()
                }
            } else {
                if animationState == .purring {
                    animationState = .idle
                }
                stopPurring()
            }
        }
    }
}

// MARK: - Setup & Cleanup
private func setupAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        // Audio session setup failed - silent fail to avoid disrupting user experience
    }
    
    audioInterruptionObserver = NotificationCenter.default.addObserver(
        forName: AVAudioSession.interruptionNotification,
        object: nil,
        queue: .main
    ) { notification in
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            stopPurring()
        }
    }
}

private func cleanup() {
    blinkTask?.cancel()
    tapAnimationTask?.cancel()
    stopPurring()
    
    do {
        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
        // Silent fail - session may already be inactive
    }
    
    if let observer = audioInterruptionObserver {
        NotificationCenter.default.removeObserver(observer)
    }
}

// MARK: - Tap Animation
private func handleTap() {
    guard animationState == .idle else { return }
    
    tapAnimationTask?.cancel()
    
    animationState = .interacting
    let randomPose = tapPoses.randomElement() ?? .shy
    
    withAnimation(.spring(response: 1.0, dampingFraction: 0.65)) {
        currentPose = randomPose
        baseScale = AppConstants.Layout.tapScale
        rotation = Double.random(in: AppConstants.Layout.tapRotationRange)
    }
    
    viewModel.showThought()
    
    tapAnimationTask = Task { @MainActor in
        try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.tapAnimation * 1_000_000_000))
        
        guard !Task.isCancelled, animationState == .interacting else { return }
        
        withAnimation(.spring()) {
            currentPose = .seated
            baseScale = 1.0
            rotation = 0
        }
        
        try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.tapReset * 1_000_000_000))
        
        guard !Task.isCancelled else { return }
        animationState = .idle
    }
}


// MARK: - Blinking
private func startBlinking() {
    blinkTask?.cancel()
    
    blinkTask = Task { @MainActor in
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64.random(in: AppConstants.AnimationDuration.blinkIntervalMin...AppConstants.AnimationDuration.blinkIntervalMax))
            
            guard !Task.isCancelled, animationState == .idle else { continue }
            
            currentPose = .blink
            
            try? await Task.sleep(nanoseconds: AppConstants.AnimationDuration.blinkDuration)
            
            guard !Task.isCancelled else { return }
            currentPose = .seated
        }
    }
}

// MARK: - Purring Audio
private func startPurring() {
    if purrPlayer != nil { return }
    
    guard let url = Bundle.main.url(forResource: AppConstants.Audio.purrFileName, withExtension: AppConstants.Audio.purrFileExtension) else {
        return
    }
    
    do {
        let player = try AVAudioPlayer(contentsOf: url)
        player.numberOfLoops = -1
        player.volume = AppConstants.Audio.purrVolume
        player.prepareToPlay()
        
        if purrPlayer == nil {
            purrPlayer = player
            player.play()
        }
    } catch {
        // Audio playback failed - silent fail to avoid disrupting user experience
    }
}

private func stopPurring() {
    purrPlayer?.stop()
    purrPlayer = nil
}

}
// MARK: - Hearts Effect
struct HeartsEffect: View {
    @State private var hearts: [HeartParticle] = []
    @State private var timer: Timer?
    @State private var cleanupTasks: [UUID: Task<Void, Never>] = [:]
    
    private let maxHearts = AppConstants.Particles.maxCount
    
    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundColor(.pink)
                    .offset(x: heart.x, y: heart.y)
                    .opacity(heart.opacity)
                    .scaleEffect(heart.scale)
            }
        }
        .onAppear {
            startHeartAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            cleanupTasks.values.forEach { $0.cancel() }
            cleanupTasks.removeAll()
        }
    }
    
    private func startHeartAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: AppConstants.Particles.heartInterval, repeats: true) { _ in
            if hearts.count >= maxHearts {
                if let oldest = hearts.first {
                    hearts.removeAll { $0.id == oldest.id }
                    cleanupTasks[oldest.id]?.cancel()
                    cleanupTasks.removeValue(forKey: oldest.id)
                }
            }
            
            let newHeart = HeartParticle(
                x: CGFloat.random(in: AppConstants.Particles.heartXRange),
                y: CGFloat.random(in: AppConstants.Particles.heartYRange),
                size: CGFloat.random(in: AppConstants.Particles.heartSizeRange)
            )
            hearts.append(newHeart)
            
            withAnimation(.easeOut(duration: AppConstants.AnimationDuration.heartFade)) {
                if let index = hearts.firstIndex(where: { $0.id == newHeart.id }) {
                    hearts[index].opacity = 0
                    hearts[index].y -= 50
                    hearts[index].scale = 1.5
                }
            }
            
            let heartId = newHeart.id
            cleanupTasks[heartId] = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.heartFade * 1_000_000_000))
                guard !Task.isCancelled else { return }
                hearts.removeAll { $0.id == heartId }
                cleanupTasks.removeValue(forKey: heartId)
            }
        }
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
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
    @State private var timer: Timer?
    @State private var cleanupTasks: [UUID: Task<Void, Never>] = [:]
    
    private let maxStars = AppConstants.Particles.maxCount
    
    var body: some View {
        ZStack {
            ForEach(stars) { star in
                Image(systemName: "star.fill")
                    .font(.system(size: star.size))
                    .foregroundColor(.yellow)
                    .offset(x: star.x, y: star.y)
                    .opacity(star.opacity)
                    .rotationEffect(.degrees(star.rotation))
                    .scaleEffect(star.scale)
            }
        }
        .onAppear {
            startStarAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            cleanupTasks.values.forEach { $0.cancel() }
            cleanupTasks.removeAll()
        }
    }
    
    private func startStarAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: AppConstants.Particles.starInterval, repeats: true) { _ in
            if stars.count >= maxStars {
                if let oldest = stars.first {
                    stars.removeAll { $0.id == oldest.id }
                    cleanupTasks[oldest.id]?.cancel()
                    cleanupTasks.removeValue(forKey: oldest.id)
                }
            }
            
            let newStar = StarParticle(
                x: CGFloat.random(in: AppConstants.Particles.starXRange),
                y: CGFloat.random(in: AppConstants.Particles.starYRange),
                size: CGFloat.random(in: AppConstants.Particles.starSizeRange)
            )
            stars.append(newStar)
            
            withAnimation(.easeInOut(duration: AppConstants.AnimationDuration.starFade)) {
                if let index = stars.firstIndex(where: { $0.id == newStar.id }) {
                    stars[index].opacity = 0
                    stars[index].rotation = 360
                    stars[index].scale = 0.3
                }
            }
            
            let starId = newStar.id
            cleanupTasks[starId] = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.starFade * 1_000_000_000))
                guard !Task.isCancelled else { return }
                stars.removeAll { $0.id == starId }
                cleanupTasks.removeValue(forKey: starId)
            }
        }
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
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
