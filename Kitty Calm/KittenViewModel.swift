//
//  KittenViewModel.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI
import Combine

class KittenViewModel: ObservableObject {
    @Published var showThoughtBubble: Bool = false
    @Published var currentThought: String = ""
    @Published var showHearts: Bool = false
        @Published var showStars: Bool = false
        @Published var isPurring: Bool = false
    
    private var lastThought: String?
        
        func showThought() {
            if showThoughtBubble {
                withAnimation(.easeOut(duration: 0.2)) {
                    showThoughtBubble = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.currentThought = ThoughtGenerator.randomThought(excluding: self.lastThought)
                    self.lastThought = self.currentThought
                    
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.showThoughtBubble = true
                    }
                }
            } else {
                currentThought = ThoughtGenerator.randomThought(excluding: lastThought)
                lastThought = currentThought
                
                withAnimation(.easeIn(duration: 0.3)) {
                    showThoughtBubble = true
                }
            }
        }
    }
