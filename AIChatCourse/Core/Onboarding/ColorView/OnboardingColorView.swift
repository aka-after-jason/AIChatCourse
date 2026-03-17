//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

struct OnboardingColorView: View {
    let colors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    @State private var selectedColor: Color?
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
                        if selectedColor != nil {
                            ctaButton
                                .transition(AnyTransition.move(edge: .bottom))
                        }
                    }
                    .padding(24)
                    .background(
                        Color(uiColor: .systemBackground)
                    )
                }
            )
            .animation(.bouncy, value: selectedColor)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
}

extension OnboardingColorView {
    private var ctaButton: some View {
        NavigationLink {} label: {
            Text("Continue")
                .callToActionButton()
        }
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
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                } header: {
                    Text("Select a profile color")
                }
            }
        )
    }
}
