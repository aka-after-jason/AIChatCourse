//
//  RevenueCatPaywallView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

import SwiftUI

import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    var body: some View {
        RevenueCatUI.PaywallView(displayCloseButton: true)
    }
}

#Preview {
    RevenueCatPaywallView()
}
