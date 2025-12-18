//
//  ThoughtGenerator.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import Foundation

struct ThoughtGenerator {
    private static let thoughts = [
        "I deserve a nap.",
        "Pet me. Or don't. I'll decide.",
        "This spot is acceptable.",
        "I was not asleep.",
        "The sunbeam is mine now.",
        "You may continue.",
        "I require attention.",
        "This is fine. For now.",
        "I'm judging your choices.",
        "The box is calling to me.",
        "I'll allow this.",
        "I'm plotting something.",
        "You're lucky I'm here.",
        "I need more treats.",
        "The window is interesting.",
        "I'm not ignoring you. I'm busy.",
        "This pillow is mine.",
        "I'll think about it.",
        "The red dot must be caught.",
        "I'm the boss here."
    ]
    
    static func randomThought(excluding: String?) -> String {
        var availableThoughts = thoughts
        if let excluding = excluding {
            availableThoughts.removeAll { $0 == excluding }
        }
        return availableThoughts.randomElement() ?? "I deserve a nap."
    }
}
