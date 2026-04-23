//
//  ProfileModalView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/23.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImageUrl
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXmarkPressed: (() -> Void) = {}
    var body: some View {
        VStack(alignment: .leading) {
            if let imageName {
                ImageLoaderView(urlString: imageName, forceTransitionAnimation: true)
                    .aspectRatio(1, contentMode: .fit)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(title ?? "")
                    .font(.title)

                Text(subtitle ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(headline ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .topTrailing) {
            Button(action: {}, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.black)
                    .padding(4) // 增大点击面积
                    .tappableBackground() // 将增大的面积设置为透明
                    .anyButton {
                        onXmarkPressed()
                    }
                    .padding(8)
            })
        }
    }
}

#Preview("Modal with Image") {
    ZStack {
        Color.gray.ignoresSafeArea()

        ProfileModalView()
            .padding(40)
    }
}

#Preview("Modal without Image") {
    ZStack {
        Color.gray.ignoresSafeArea()

        ProfileModalView(imageName: nil)
            .padding(40)
    }
}
