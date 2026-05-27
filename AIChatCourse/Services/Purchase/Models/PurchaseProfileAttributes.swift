//
//  PurchaseProfileAttributes.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/27.
//

import SwiftUI

struct PurchaseProfileAttributes {
    let email: String?
    let firebaseAppInstanceID: String?
    let mixpanelDistinctID: String?
    
    init(email: String? = nil, firebaseAppInstanceID: String? = nil, mixpanelDistinctID: String? = nil) {
        self.email = email
        self.firebaseAppInstanceID = firebaseAppInstanceID
        self.mixpanelDistinctID = mixpanelDistinctID
    }
}
