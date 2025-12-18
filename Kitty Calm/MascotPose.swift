import SwiftUI

enum MascotPose: CaseIterable {
    case seated
    case shy
    case surprised
    case sleeping
    case wavingHand
    case happy
    case helloWave
    case wavingHands
    case blink

    var imageName: String {
        switch self {
        case .seated:       return "kitten"
        case .shy:          return "shy"
        case .surprised:    return "surprised"
        case .sleeping:     return "sleeping"
        case .wavingHand:   return "waving_hand"
        case .happy:        return "happy"
        case .helloWave:    return "hello_wave"
        case .wavingHands:  return "waving_hands"
        case .blink:        return "blink"
        }
    }

    /// Насколько конкретная поза больше/меньше
    var heightMultiplier: CGFloat {
        switch self {
        case .seated:
            return 1.13
        default:
            return 1.0
        }
    }
}
