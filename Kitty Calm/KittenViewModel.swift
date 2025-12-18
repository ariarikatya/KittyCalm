import SwiftUI
import Combine

class KittenViewModel: ObservableObject {
    @Published var showThoughtBubble: Bool = false
    @Published var currentThought: String = ""
    @Published var showHearts: Bool = false
    @Published var showStars: Bool = false
    @Published var isPurring: Bool = false
    
    private var lastThought: String?
    private var thoughtTask: Task<Void, Never>?
    
    func showThought() {
        thoughtTask?.cancel()
        
        if showThoughtBubble {
            withAnimation(.easeOut(duration: AppConstants.AnimationDuration.short)) {
                showThoughtBubble = false
            }
            
            thoughtTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.AnimationDuration.short * 1_000_000_000))
                
                guard !Task.isCancelled else { return }
                
                currentThought = ThoughtGenerator.randomThought(excluding: lastThought)
                lastThought = currentThought
                
                withAnimation(.easeIn(duration: AppConstants.AnimationDuration.short)) {
                    showThoughtBubble = true
                }
            }
        } else {
            currentThought = ThoughtGenerator.randomThought(excluding: lastThought)
            lastThought = currentThought
            
            withAnimation(.easeIn(duration: AppConstants.AnimationDuration.medium)) {
                showThoughtBubble = true
            }
        }
    }
    
    deinit {
        thoughtTask?.cancel()
    }
}
