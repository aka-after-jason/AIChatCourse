//
//  HeroCellView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/17.
//

import SwiftUI

struct HeroCellView: View {
    var title: String? = "This is some title"
    var subTitle: String? = "This is some subtitle that will go here."
    var imageName: String? = Constants.randomImageUrl
    var body: some View {
        ZStack {
            if let imageName {
                ImageLoaderView(urlString: imageName)
            } else {
                Rectangle()
                    .fill(.accent)
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                if let subTitle {
                    Text(subTitle)
                        .font(.subheadline)
                }
            }
            .foregroundStyle(.white)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                // 来个渐变色,便于观察字体
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .cornerRadius(16)
    }
}

#Preview {
    
    VStack {
        ScrollView {
            HeroCellView(title: nil)
                .frame(width: 300, height: 200)
            HeroCellView(imageName: nil)
                .frame(width: 300, height: 200)
            HeroCellView(subTitle: nil)
                .frame(width: 300, height: 200)
        }
    }
    .frame(maxWidth: .infinity)
}
