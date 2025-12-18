import Foundation

struct ThoughtGenerator {

    private static let thoughts: [String] = [
        // Calm / cozy
        "I deserve a nap.",
        "This spot is warm and perfect.",
        "Slow breaths. Like this.",
        "Everything feels soft right now.",
        "The world can wait.",
        "I'm cozy. Stay here.",
        
        // Attitude / funny
        "Pet me. Or don't. I'll decide.",
        "I was not asleep.",
        "You may continue.",
        "I'll allow this.",
        "I'm judging your choices.",
        "You're lucky I'm here.",
        "This is fine. For now.",
        
        // Curious
        "The window is interesting.",
        "Something moved. I felt it.",
        "The red dot must be caught.",
        "What is that sound?",
        "The box is calling to me.",
        "I must investigate.",
        
        // Needy / cute
        "I require attention.",
        "I need more treats.",
        "Stay with me a little longer.",
        "Touch my head. Yes, there.",
        "Don't stop.",
        
        // Silly
        "I forgot what I was thinking.",
        "I'm plotting something.",
        "I'm the boss here.",
        "This pillow is mine.",
        "I'll think about it."
    ]

    static func randomThought(excluding: String?) -> String {
        var availableThoughts = thoughts
        if let excluding = excluding {
            availableThoughts.removeAll { $0 == excluding }
        }
        return availableThoughts.randomElement() ?? "I deserve a nap."
    }
    }
