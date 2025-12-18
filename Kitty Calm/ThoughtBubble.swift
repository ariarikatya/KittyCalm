//
//  ThoughtBubble.swift
//  Kitty Calm
//
//  Created by Екатерина Аристова on 18.12.2025.
//

import SwiftUI

struct ThoughtBubble: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                // Облако (3 круга)
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 120)
                    .offset(x: -30)

                Circle()
                    .fill(Color.white)
                    .frame(width: 220, height: 130)
                    .offset(x: 30)

                Circle()
                    .fill(Color.white)
                    .frame(width: 240, height: 140)

                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)

            // Мысли → К ГОЛОВЕ
            VStack(spacing: 6) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)

                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: -6)

                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .offset(x: -12)
            }
        }
    }
}
