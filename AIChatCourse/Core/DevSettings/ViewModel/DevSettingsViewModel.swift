//
//  DevSettingsViewModel.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/7.
//
import SwiftUI
import SwiftfulUtilities

protocol DevSettingsViewModelInteractor {
    var activeABTestModel: ActiveABTestModel { get }
    var currentUser: UserModel? { get }
    var authUser: UserAuthInfoModel? { get }
    func override(updateABTestModel: ActiveABTestModel) throws
}

extension CoreInteractor: DevSettingsViewModelInteractor {}

@MainActor
@Observable
final class DevSettingsViewModel {
    private let interactor: DevSettingsViewModelInteractor
    init(interactor: DevSettingsViewModelInteractor) {
        self.interactor = interactor
    }

    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    var paywallTest: PaywallTestOption = .default

    var activeABTestModel: ActiveABTestModel {
        interactor.activeABTestModel
    }

    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var authData: [(key: String, value: Any)] {
        interactor.authUser?.eventParams.asAlphabeticalArray ?? []
    }
    
    var utilitiesData: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalArray
    }

    func loadABTest() {
        createAccountTest = interactor.activeABTestModel.createAccountTest
        onboardingCommunityTest = interactor.activeABTestModel.onboardingCommunityTest
        categoryRowTest = interactor.activeABTestModel.categroyRowTest
        paywallTest = interactor.activeABTestModel.paywallTest
    }

    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        if newValue != interactor.activeABTestModel.createAccountTest {
            do {
                var testModel = interactor.activeABTestModel
                testModel.update(createAccountTest: newValue)
                try interactor.override(updateABTestModel: testModel)
            } catch {
                createAccountTest = interactor.activeABTestModel.createAccountTest
                print("error: \(error.localizedDescription)")
            }
        }
    }

    func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        // 使用封装的方法
        updateTestModel(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: interactor.activeABTestModel.onboardingCommunityTest,
            updateAction: { testModel in
                testModel.update(onboardingCommunityTest: newValue)
            }
        )

        /*
         if newValue != abtestManager.activeABTestModel.onboardingCommunityTest {
             do {
                 var testModel = abtestManager.activeABTestModel
                 testModel.update(onboardingCommunityTest: newValue)
                 try abtestManager.override(updateABTestModel: testModel)
             } catch {
                 onboardingCommunityTest = abtestManager.activeABTestModel.onboardingCommunityTest
                 print("error: \(error.localizedDescription)")
             }
         }
          */
    }

    /// 封装一个方法
    private func updateTestModel<T: Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTestModel) -> Void
    ) {
        if newValue != savedValue {
            do {
                var testModel = interactor.activeABTestModel
                updateAction(&testModel)
                try interactor.override(updateABTestModel: testModel)
            } catch {
                property = savedValue
            }
        }
    }

    func handleCategoryRowTestChange(oldValue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        // 使用封装的方法
        updateTestModel(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: interactor.activeABTestModel.categroyRowTest,
            updateAction: { testModel in
                testModel.update(categoryRowTest: newValue)
            }
        )
    }

    func handlePaywallTestChange(oldValue: PaywallTestOption, newValue: PaywallTestOption) {
        // 使用封装的方法
        updateTestModel(
            property: &paywallTest,
            newValue: newValue,
            savedValue: interactor.activeABTestModel.paywallTest,
            updateAction: { testModel in
                testModel.update(paywallTest: newValue)
            }
        )
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        onDismiss()
    }
}
