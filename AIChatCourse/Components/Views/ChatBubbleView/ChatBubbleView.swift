//
//  ChatBubbleView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct ChatBubbleView: View {
    var text: String = "This is sample text."
    var textColor: Color = .primary
    var backgroundColor: Color = .init(uiColor: .systemGray6)
    var imageName: String?
    var showImage: Bool = true
    let offset: CGFloat = 14
    var onImagePressed: (() -> Void)?
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        Button(action: {onImagePressed?()}, label: {
                            ImageLoaderView(urlString: imageName)
                        })
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offset)
            }

            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ChatBubbleView()
            ChatBubbleView(text: "foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle")
            ChatBubbleView()

            ChatBubbleView(
                text: "foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle foregroundStyle",
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
        }
        .padding(8)
    }
}
