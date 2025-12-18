import SwiftUI

struct ThoughtBubble: View {
    let text: String

    var body: some View {
        VStack(spacing: 8) {

            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                )

            // хвост мысли
            VStack(spacing: 6) {
                Circle().fill(Color.white).frame(width: 10, height: 10)
                Circle().fill(Color.white).frame(width: 6, height: 6)
                Circle().fill(Color.white).frame(width: 4, height: 4)
            }
            .offset(x: -20)
        }
    }
}
