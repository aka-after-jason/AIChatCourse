//
//  UserAuthInfoModel+Firebase.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/4/24.
//

import FirebaseAuth

extension UserAuthInfoModel {
    
    init(user: User) { // User from firebase
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
    
}
