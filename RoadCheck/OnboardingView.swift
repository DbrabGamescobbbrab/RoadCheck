import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    let systemImage: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var index = 0

    private let pages: [OnboardingPage] = [
        .init(titleKey: "onb_title_1", subtitleKey: "onb_sub_1", systemImage: "flame.fill"), // огонёк
        .init(titleKey: "onb_title_2", subtitleKey: "onb_sub_2", systemImage: "chart.bar.doc.horizontal.fill"),
        .init(titleKey: "onb_title_3", subtitleKey: "onb_sub_3", systemImage: "lock.circle.fill")
    ]

    var body: some View {
        VStack {
            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.offset) { i, p in
                    VStack(spacing: 20) {
                        Spacer(minLength: 12)
                        Image(systemName: p.systemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .symbolRenderingMode(.hierarchical)
                            .padding(.top, 8)

                        Text(p.titleKey)
                            .font(.title).bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(p.subtitleKey)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer()
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack {
                if index < pages.count - 1 {
                    Button(LocalizedStringKey("onb_continue")) {
                        withAnimation { index += 1 }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)

                    .font(.title3.bold())
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Button(LocalizedStringKey("onb_get_started")) {
                        hasSeenOnboarding = true
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)

                    .font(.title3.bold())
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24) // повыше
        }
    }
}
