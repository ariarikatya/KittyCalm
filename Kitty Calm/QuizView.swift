import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctIndex: Int
    let fact: String
}

struct QuizView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var questions: [QuizQuestion] = QuizView.makeQuestions()
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var hasAnswered: Bool = false
    @State private var showResult: Bool = false
    
    private var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            if showResult {
                QuizResultView(onDone: {
                    dismiss()
                })
            } else if let question = currentQuestion {
                VStack(spacing: 24) {
                    Text("Cat Curious Quiz")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .padding(.top, 24)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Question \(currentIndex + 1) of \(questions.count)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .accessibilityLabel("Question \(currentIndex + 1) of \(questions.count)")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.question)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(question.options.indices, id: \.self) { index in
                            AnswerButton(
                                text: question.options[index],
                                isSelected: selectedIndex == index,
                                showResult: hasAnswered,
                                isCorrect: index == question.correctIndex
                            ) {
                                guard !hasAnswered else { return }
                                selectedIndex = index
                                hasAnswered = true
                            }
                            .accessibilityLabel("Option \(index + 1): \(question.options[index])")
                            .accessibilityHint(index == question.correctIndex ? "This is the correct answer" : "")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    if hasAnswered, let selectedIndex = selectedIndex {
                        VStack(spacing: 8) {
                            Text(selectedIndex == question.correctIndex ? "Paw-sitively right!" : "Nice try, tiny human.")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppConstants.Colors.textSuccess)
                                .accessibilityAddTraits(selectedIndex == question.correctIndex ? .isHeader : [])
                            
                            Text(question.fact)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppConstants.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .accessibilityLabel("Fun fact: \(question.fact)")
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    CustomButton(title: currentIndex == questions.count - 1 ? "See my reward" : "Next question") {
                        if currentIndex == questions.count - 1 {
                            showResult = true
                        } else {
                            withAnimation(.easeInOut(duration: AppConstants.AnimationDuration.short)) {
                                currentIndex += 1
                                selectedIndex = nil
                                hasAnswered = false
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)
                    .disabled(!hasAnswered)
                    .opacity(hasAnswered ? 1.0 : 0.5)
                    .accessibilityHint(hasAnswered ? "" : "Answer a question to continue")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Cat Quiz", displayMode: .inline)
    }
    
    private static func makeQuestions() -> [QuizQuestion] {
        let all: [QuizQuestion] = [
            
            QuizQuestion(
                question: "Why do many cats purr?",
                options: [
                    "Only when they are angry",
                    "To communicate comfort and calm",
                    "So humans bring more toys",
                    "To see in the dark"
                ],
                correctIndex: 1,
                fact: "Cats often purr when they feel relaxed or safe, and sometimes to comfort themselves when they are unwell."
            ),
            
            QuizQuestion(
                question: "What is usually the safest way to say hello to a new cat?",
                options: [
                    "Pick them up straight away",
                    "Offer your hand and let them come to you",
                    "Stare directly into their eyes",
                    "Make loud clapping sounds"
                ],
                correctIndex: 1,
                fact: "Letting a cat choose to approach you helps them feel safe and respected."
            ),
            
            QuizQuestion(
                question: "Why do cats like high places?",
                options: [
                    "They think they can fly",
                    "To observe safely from above",
                    "Because the floor is boring",
                    "To hide from humans"
                ],
                correctIndex: 1,
                fact: "High spots help cats feel secure while watching their surroundings."
            ),
            
            QuizQuestion(
                question: "What do a cat's whiskers help them with?",
                options: [
                    "Smelling food",
                    "Measuring space and movement",
                    "Hearing better",
                    "Staying warm"
                ],
                correctIndex: 1,
                fact: "Whiskers are extremely sensitive and help cats judge spaces."
            ),
            
            QuizQuestion(
                question: "What does slow blinking from a cat usually mean?",
                options: [
                    "They are tired",
                    "They trust you",
                    "They are angry",
                    "They are bored"
                ],
                correctIndex: 1,
                fact: "Slow blinking is a sign of trust and comfort in cats."
            ),
            
            QuizQuestion(
                question: "Why do cats knead with their paws?",
                options: [
                    "To sharpen claws",
                    "Because they learned it as kittens",
                    "To stretch their legs",
                    "To annoy humans"
                ],
                correctIndex: 1,
                fact: "Kneading comes from kittenhood and is linked to comfort and safety."
            ),
            
            QuizQuestion(
                question: "What sound can calm many cats?",
                options: [
                    "Loud music",
                    "Sudden noises",
                    "Soft, steady sounds",
                    "Clapping"
                ],
                correctIndex: 2,
                fact: "Gentle and consistent sounds can help cats relax."
            )
        ]
        
        return Array(all.shuffled().prefix(3))
    }
    
    // MARK: - Answer Button
    struct AnswerButton: View {
        let text: String
        let isSelected: Bool
        let showResult: Bool
        let isCorrect: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(foregroundColour)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(backgroundColour)
                        .shadow(color: shadowColour.opacity(0.15), radius: 6, x: 0, y: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        private var backgroundColour: Color {
            if showResult {
                return isCorrect ? AppConstants.Colors.correctAnswerBackground : Color.white
            }
            return isSelected ? AppConstants.Colors.selectedBackground : Color.white
        }
        
        private var foregroundColour: Color {
            if showResult && isCorrect {
                return AppConstants.Colors.textSuccessDark
            }
            return AppConstants.Colors.textPrimary
        }
        
        private var shadowColour: Color {
            if showResult && isCorrect {
                return AppConstants.Colors.textSuccessDark
            }
            return Color.black
        }
    }
    
    // MARK: - Quiz Result View
    struct QuizResultView: View {
        let onDone: () -> Void
        
        private let rewardImageName: String = {
            let names = ["kitten_01", "kitten_02", "kitten_03", "kitten_04", "kitten_05"]
            return names.randomElement() ?? "kitten_01"
        }()
        
        var body: some View {
            VStack(spacing: 28) {
                Spacer()
                
                Text("Purr-fect effort!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Here is a special kitten just for you.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppConstants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Image(rewardImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260, maxHeight: 320)
                    .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel("Reward kitten image")
                
                Spacer()
                
                CustomButton(title: "Back to kitty") {
                    onDone()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            }
        }
    }
}
