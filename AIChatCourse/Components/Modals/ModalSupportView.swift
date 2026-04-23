//
//  ModalSupportView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/23.
//

import SwiftUI

// MARK: Reusable modal

struct ModalSupportView<Content: View>: View {
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            if self.showModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(AnyTransition.opacity.animation(.smooth))
                    .onTapGesture {
                        self.showModal = false
                    }
                    .zIndex(1)

                self.content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2) // 内容始终显示在背景上面
            }
        }
        .zIndex(9999)
        .animation(.bouncy, value: self.showModal)
    }
}

extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay {
                ModalSupportView(showModal: showModal) {
                    content()
                }
            }
    }
}

private struct PreviewView: View {
    @State private var showModal: Bool = false
    var body: some View {
        Button("Click me") {
            self.showModal = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModal(showModal: self.$showModal) {
            RoundedRectangle(cornerRadius: 20)
                .padding(40)
                .padding(.vertical, 100)
                // .transition(.slide)
                .transition(.move(edge: .trailing))
        }
    }
}

#Preview {
    PreviewView()
}
