import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.75, green: 0.84, blue: 0.96),
                            Color(red: 0.68, green: 0.80, blue: 0.94)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 0.55, green: 0.70, blue: 0.88).opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToggleButton: View {
    let title: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isOn ? .white : Color(red: 0.55, green: 0.70, blue: 0.88))
                .frame(height: 36)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isOn ? Color(red: 0.75, green: 0.84, blue: 0.96) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(red: 0.75, green: 0.84, blue: 0.96), lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

