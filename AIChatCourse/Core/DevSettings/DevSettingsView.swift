//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import SwiftfulUtilities
import SwiftUI

struct DevSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abtestManager
    @State private var createAccountTest: Bool = false
    @State private var onboardingCommunityTest: Bool = false
    var body: some View {
        // This is a sheet, new environment
        NavigationStack {
            List {
                abtestSection
                authInfoSection
                userInfoSection
                deviceInfoSection
            }
            .navigationTitle("Dev Settings 🤗")
            .appearAnalyticsViewModifier(name: "DevSettings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .onFirstAppear {
                loadABTest()
            }
        }
    }

    private func loadABTest() {
        createAccountTest = abtestManager.activeABTestModel.createAccountTest
        onboardingCommunityTest = abtestManager.activeABTestModel.onboardingCommunityTest
    }

    private func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        if newValue != abtestManager.activeABTestModel.createAccountTest {
            do {
                var testModel = abtestManager.activeABTestModel
                testModel.update(createAccountTest: newValue)
                try abtestManager.override(updateABTestModel: testModel)
            } catch {
                createAccountTest = abtestManager.activeABTestModel.createAccountTest
                print("error: \(error.localizedDescription)")
            }
        }
    }

    private func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        
        // 使用封装的方法
        updateTestModel(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: abtestManager.activeABTestModel.onboardingCommunityTest,
            updateAction: {testModel in
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
    private func updateTestModel(
        property: inout Bool,
        newValue: Bool,
        savedValue: Bool,
        updateAction: (inout ActiveABTestModel) -> Void
    ) {
        if newValue != savedValue {
            do {
                var testModel = abtestManager.activeABTestModel
                updateAction(&testModel)
                try abtestManager.override(updateABTestModel: testModel)
            } catch {
                property = savedValue
            }
        }
    }

    private var abtestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreateAccountChange)

            Toggle("Onboarding Community Test", isOn: $onboardingCommunityTest)
                .onChange(of: onboardingCommunityTest, handleOnboardingCommunityChange)
        } header: {
            Text("ABTest")
        }
        .font(.caption)
    }

    private var deviceInfoSection: some View {
        Section {
            let array = Utilities.eventParameters.asAlphabeticalArray
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }

    private var userInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            let array = userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }

    private var authInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            let array = authManager.authUser?.eventParams.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }

    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
