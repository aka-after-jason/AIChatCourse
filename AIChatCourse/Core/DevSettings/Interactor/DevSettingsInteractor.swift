//
//  DevSettingsInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/10.
//
import SwiftUI

@MainActor
protocol DevSettingsInteractor {
    var activeABTestModel: ActiveABTestModel { get }
    var currentUser: UserModel? { get }
    var authUser: UserAuthInfoModel? { get }
    func override(updateABTestModel: ActiveABTestModel) throws
}
extension CoreInteractor: DevSettingsInteractor {}
