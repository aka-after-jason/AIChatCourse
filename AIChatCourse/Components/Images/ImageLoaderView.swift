//
//  ImageLoaderView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SDWebImageSwiftUI
import SwiftUI

struct ImageLoaderView: View {
    var urlString: String = Constants.randomImageUrl
    var resizingMode: ContentMode = .fill
    var forceTransitionAnimation: Bool = false
    var body: some View {
        Rectangle()
            .opacity(0.5)
            .overlay { // 注意: 这里
                WebImage(url: URL(string: urlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
            }
            .clipped()
        // Composites this view’s contents into an offscreen image before final display.
        // .drawingGroup() // 解决ChatView中点击图像的动画问题
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content.drawingGroup()
            }
    }
}

extension View {
    @ViewBuilder
    func ifSatisfiedCondition(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 100, height: 200) // WebImage不放在Rectangle里面,这个frame是正方形
}
