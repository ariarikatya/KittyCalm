import SwiftUI
import Combine  

final class ThemeManager: ObservableObject {
    @Published var backgroundColor: Color = Color(red: 0.98, green: 0.97, blue: 0.92)

    static let pastelBackgrounds: [(name: String, color: Color)] = [
        ("Pastel Green", Color(red: 0.88, green: 0.95, blue: 0.88)),
        ("Pastel Pink", Color(red: 0.98, green: 0.89, blue: 0.94)),
        ("Pastel Blue", Color(red: 0.90, green: 0.94, blue: 0.99)),
        ("Pastel Beige", Color(red: 0.97, green: 0.94, blue: 0.88)),
        ("Pastel Yellow", Color(red: 0.99, green: 0.97, blue: 0.86))
    ]
}
