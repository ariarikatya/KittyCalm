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
@State private var breathingScale: CGFloat = 1.0
@State private var rotation: Double = 0
@State private var animationState: MascotAnimationState = .idle

// MARK: - Interaction state
@State private var isAnimating = false
@State private var isPetting = false

// MARK: - Audio & Haptics
private let haptic = UIImpactFeedbackGenerator(style: .soft)
@State private var purrPlayer: AVAudioPlayer?
@State private var audioInterruptionObserver: NSObjectProtocol?

// MARK: - Tasks
@State private var blinkTask: Task<Void, Never>?
@State private var stateResetTask: Task<Void, Never>?

private let tapPoses: [MascotPose] = [
    .shy, .happy, .surprised, .wavingHand,
    .helloWave, .sleeping, .wavingHands
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
            
            if viewModel.showHearts {
                HeartsEffect()
            }
            
            if viewModel.showStars {
                StarsEffect()
            }
            
            if viewModel.showThoughtBubble {
                ThoughtBubble(text: viewModel.currentThought)
                    .offset(y: -kittenHeight * 0.75)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            print("🔵 Tap detected - current state: \(animationState)")
            
            if viewModel.isPurring {
                viewModel.isPurring = false
                stopPurring()
                animationState = .idle
                print("✅ Purring stopped via tap")
            } else if animationState == .purring {
                
                stopPurring()
                animationState = .idle
                print("✅ Reset from stuck purring state")
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
                        print("✅ Drag ended - ready for taps")
                    }
                    isPetting = false
                }
        )
        .onAppear {
            setupAudioSession()
            startBreathing()
            startBlinking()
        }
        .onDisappear {
            cleanup()
        }
        .onChange(of: viewModel.isPurring) { newValue in
            print("🟡 isPurring changed to: \(newValue)")
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
        print("Failed to setup audio session: \(error)")
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
    stateResetTask?.cancel()
    stopPurring()
    
    if let observer = audioInterruptionObserver {
        NotificationCenter.default.removeObserver(observer)
    }
}

// MARK: - Tap Animation
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
        guard self.animationState == .interacting else { return }
        
        withAnimation(.spring()) {
            currentPose = .seated
            baseScale = 1.0
            rotation = 0
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animationState = .idle
        }
    }
}

// MARK: - Breathing
private func startBreathing() {
    withAnimation(
        .easeInOut(duration: 2.8)
            .repeatForever(autoreverses: true)
    ) {
        breathingScale = 1.03
    }
}

// MARK: - Blinking
private func startBlinking() {
    blinkTask?.cancel()
    
    blinkTask = Task { @MainActor in
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 4_000_000_000...8_000_000_000))
            
            guard animationState == .idle else { continue }
            
            currentPose = .blink
            
            try? await Task.sleep(nanoseconds: 220_000_000)
            
            currentPose = .seated
        }
    }
}

// MARK: - Purring Audio
private func startPurring() {
    guard purrPlayer == nil else { return }
    guard let url = Bundle.main.url(forResource: "purr", withExtension: "mp3") else {
        print("Purr sound file not found")
        return
    }
    
    do {
        purrPlayer = try AVAudioPlayer(contentsOf: url)
        purrPlayer?.numberOfLoops = -1
        purrPlayer?.volume = 0.5
        purrPlayer?.prepareToPlay()
        purrPlayer?.play()
    } catch {
        print("Error playing purr sound: \(error)")
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
        }
    }
    
    private func startHeartAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
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
        }
    }
    
    private func startStarAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
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
