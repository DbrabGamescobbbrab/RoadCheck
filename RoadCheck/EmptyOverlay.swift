import SwiftUI

struct EmptyOverlay: View {
    let textKey: LocalizedStringKey
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .font(.system(size: 44, weight: .regular))
                .symbolRenderingMode(.hierarchical)
            Text(textKey)
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
