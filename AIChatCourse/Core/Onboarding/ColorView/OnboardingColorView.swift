//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

struct OnboardingColorDelete {
    var path: Binding<[NavOnboardingPathOption]>
}

struct OnboardingColorView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: OnboardingColorViewModel
    let delegate: OnboardingColorDelete
    var body: some View {
        VStack {
            ScrollView {
                colorGrid
                    .padding(.horizontal, 24)
            }
            .safeAreaInset(
                edge: .bottom,
                alignment: .center,
                spacing: 16,
                content: {
                    ZStack {
                        if let selectedColor = viewModel.selectedColor {
                            ctaButton(selectedColor: selectedColor)
                                .transition(AnyTransition.move(edge: .bottom))
                        }
                    }
                    .padding(24)
                    .background(
                        Color(uiColor: .systemBackground)
                    )
                }
            )
            .toolbar(.hidden, for: .navigationBar)
            .animation(.bouncy, value: viewModel.selectedColor)
            .appearAnalyticsViewModifier(name: "OnboardingColorView")
        }
    }
}

extension OnboardingColorView {
    private func ctaButton(selectedColor: Color) -> some View {
        Text("Continue")
            .callToActionButton()
            .anyButton(.press, action: {
                viewModel.onContinueButtonPressed(path: delegate.path)
            })
    }

    private var colorGrid: some View {
        LazyVGrid(
            // spacing 是水平item之间的距离
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16, // 这个 spacing 是垂直item之间的距离
            pinnedViews: [.sectionHeaders],
            content: {
                Section {
                    ForEach(viewModel.colors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                color
                                    .clipShape(Circle())
                                    .padding(viewModel.selectedColor == color ? 10 : 0)
                            }
                            .onTapGesture {
                                viewModel.onColorPressed(color: color)
                            }
                    }
                } header: {
                    Text("Select a profile color")
                }
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    let delegate = OnboardingColorDelete(path: .constant([]))
    return NavigationStack {
        builder.onboardingColorView(delegate: delegate)
            .previewEnvironment()
    }
}
