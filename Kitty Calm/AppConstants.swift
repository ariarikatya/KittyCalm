import SwiftUI

enum AppConstants {
    // MARK: - Colors
    enum Colors {
        static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.2)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
        static let textTertiary = Color(red: 0.25, green: 0.25, blue: 0.25)
        static let textSuccess = Color(red: 0.3, green: 0.4, blue: 0.2)
        static let textSuccessDark = Color(red: 0.12, green: 0.35, blue: 0.20)
        static let backgroundBeige = Color(red: 0.96, green: 0.94, blue: 0.90)
        static let buttonBlue = Color(red: 0.75, green: 0.84, blue: 0.96)
        static let buttonBlueDark = Color(red: 0.68, green: 0.80, blue: 0.94)
        static let buttonBlueLight = Color(red: 0.55, green: 0.70, blue: 0.88)
        static let selectedBackground = Color(red: 0.90, green: 0.92, blue: 0.96)
        static let correctAnswerBackground = Color(red: 0.80, green: 0.93, blue: 0.82)
        static let checkmarkBlue = Color(red: 0.4, green: 0.6, blue: 0.9)
    }
    
    // MARK: - Animation Durations
    enum AnimationDuration {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.4
        static let heartFade: Double = 2.0
        static let starFade: Double = 1.8
        static let tapAnimation: Double = 1.2
        static let tapReset: Double = 0.3
        static let blinkDuration: UInt64 = 220_000_000
        static let blinkIntervalMin: UInt64 = 4_000_000_000
        static let blinkIntervalMax: UInt64 = 8_000_000_000
    }
    
    // MARK: - Particle Effects
    enum Particles {
        static let maxCount = 20
        static let heartInterval: TimeInterval = 0.3
        static let starInterval: TimeInterval = 0.25
        static let heartXRange: ClosedRange<CGFloat> = -120...120
        static let heartYRange: ClosedRange<CGFloat> = -150...150
        static let heartSizeRange: ClosedRange<CGFloat> = 20...40
        static let starXRange: ClosedRange<CGFloat> = -120...120
        static let starYRange: ClosedRange<CGFloat> = -150...150
        static let starSizeRange: ClosedRange<CGFloat> = 18...35
    }
    
    // MARK: - Layout
    enum Layout {
        static let kittenMaxHeight: CGFloat = 360
        static let kittenHeightMultiplier: CGFloat = 0.6
        static let thoughtBubbleOffset: CGFloat = 0.75
        static let tapScale: CGFloat = 1.08
        static let tapRotationRange: ClosedRange<Double> = -6...6
        static let breathingScale: CGFloat = 1.03
    }
    
    // MARK: - Audio
    enum Audio {
        static let purrVolume: Float = 0.5
        static let purrFileName = "purr"
        static let purrFileExtension = "mp3"
    }
}

