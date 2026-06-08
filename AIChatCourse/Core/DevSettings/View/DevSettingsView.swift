//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//

import SwiftfulUtilities
import SwiftUI

struct DevSettingsView: View {
    @State var viewModel: DevSettingsViewModel
    @Environment(\.dismiss) private var dismiss
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
                    backButtonView
                }
            }
            .onFirstAppear {
                viewModel.loadABTest()
            }
        }
    }
}

extension DevSettingsView {
    private var backButtonView: some View {
        Button(action: {
            viewModel.onBackButtonPressed(onDismiss: {
                dismiss()
            })
        }, label: {
            Image(systemName: "xmark")
        })
    }
    private var abtestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $viewModel.createAccountTest)
                .onChange(of: viewModel.createAccountTest, viewModel.handleCreateAccountChange)

            Toggle("Onboarding Community Test", isOn: $viewModel.onboardingCommunityTest)
                .onChange(of: viewModel.onboardingCommunityTest, viewModel.handleOnboardingCommunityChange)

            Picker("Category Row Test", selection: $viewModel.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue).id(option)
                }
            }
            .onChange(of: viewModel.categoryRowTest, viewModel.handleCategoryRowTestChange)

            Picker("Paywall Test", selection: $viewModel.paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue).id(option)
                }
            }
            .onChange(of: viewModel.paywallTest, viewModel.handlePaywallTestChange)

        } header: {
            Text("ABTest")
        }
        .font(.caption)
    }

    private var deviceInfoSection: some View {
        Section {
            ForEach(viewModel.utilitiesData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }

    private var userInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            ForEach(viewModel.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }

    private var authInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            ForEach(viewModel.authData, id: \.key) { item in
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
    CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
        .devSettingsView()
        .previewEnvironment()
}
