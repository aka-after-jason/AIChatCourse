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
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay { // 注意: 这里
                WebImage(url: URL(string: urlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
            }
            .clipped()
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 100, height: 200) // WebImage不放在Rectangle里面,这个frame是正方形
}
