//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/24.
//

import SwiftUI

protocol ABTestService {
    var activeABTestModel: ActiveABTestModel { get }
    func saveUpdatedConfig(abtestModel: ActiveABTestModel) throws
    func fetchUpdatedConfig() async throws -> ActiveABTestModel
}
