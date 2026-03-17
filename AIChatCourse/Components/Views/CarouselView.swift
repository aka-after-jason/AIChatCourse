//
//  CarouselView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

/// 轮播图 使用泛型和@ViewBuilder 使其更通用
struct CarouselView<Content: View, T: Hashable>: View {
    let items: [T]
    @State private var selectedItem: T?
    @ViewBuilder var content: (T) -> Content
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .containerRelativeFrame(.horizontal, alignment: .center) // 分页
                            .scrollTransition(.interactive.threshold(.visible(0.95))) { content, phase in
                                content.scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
                            .id(item)
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden) // 隐藏滚动条
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging) // 分页
            .scrollPosition(id: $selectedItem)
            .onChange(of: items.count) { _, _ in
                updateSelectionIfNeeded()
            }
            .onAppear {
                updateSelectionIfNeeded()
            }

            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(selectedItem == item ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selectedItem)
        }
    }

    private func updateSelectionIfNeeded() {
        // 如果没有选择或者选到最后一个,则让selectedItem默认选中第一个
        if selectedItem == nil || selectedItem == items.last {
            selectedItem = items.first
        }
    }
}

#Preview {
    CarouselView(items: AvatarModel.mocks, content: { item in
        HeroCellView(
            title: item.name,
            subTitle: item.characterDescription,
            imageName: item.profileImageName
        )
    })
}
