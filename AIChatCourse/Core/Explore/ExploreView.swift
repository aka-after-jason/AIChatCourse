//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/16.
//

import SwiftUI

struct ExploreView: View {
    let avatar = AvatarModel.mock
    var body: some View {
        NavigationStack {
            HeroCellView(
                title: avatar.name,
                subTitle: avatar.characterDescription,
                imageName: avatar.profileImageName
            )
            .frame(height: 300)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
