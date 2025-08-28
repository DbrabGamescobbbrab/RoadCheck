



import SwiftUI
import UIKit

/// A reusable keyboard toolbar with quick category buttons (A/B/C) and Done.
/// Attach to any TextField bound to a `String` (vehicle category).
///
/// Usage:
///     TextField("Category", text: $category)
///         .categoryKeyboardToolbar(text: $category)
struct CategoryKeyboardToolbar: ViewModifier {
    @Binding var text: String
    var categories: [String] = ["A", "B", "C"]
    var includeClear: Bool = true

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(cat) {
                                    text = cat
                                }
                                .buttonStyle(.bordered)
                            }
                            if includeClear {
                                Divider().frame(height: 20)
                                Button(String(localized: "Clear")) {
                                    text = ""
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Spacer()
                    Button(String(localized: "keyboard_done")) {
                        hideKeyboard()
                    }
                }
            }
    }
}

extension View {
    /// Attach the category keyboard toolbar to a text field bound to `text`.
    func categoryKeyboardToolbar(text: Binding<String>, categories: [String] = ["A","B","C"], includeClear: Bool = true) -> some View {
        self.modifier(CategoryKeyboardToolbar(text: text, categories: categories, includeClear: includeClear))
    }
}

// MARK: - Keyboard utilities
private func hideKeyboard() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}
