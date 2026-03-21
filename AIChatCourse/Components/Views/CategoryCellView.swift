//
//  CategoryCellView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import SwiftUI

struct CategoryCellView: View {
    var title: String = "Aliens"
    var imageName: String = Constants.randomImageUrl
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    var body: some View {
        // 背景
        ImageLoaderView(urlString: imageName)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .padding(16)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .addingGradientBackgroundForText()
            }
            .cornerRadius(cornerRadius)
    }
}

#Preview {
    CategoryCellView()
        .frame(height: 150)
}
