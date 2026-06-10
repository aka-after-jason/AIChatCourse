//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/4.
//
import SwiftUI

struct DevSettingsView: View {
    @State var presenter: DevSettingsPresenter
    var body: some View {
        // This is a sheet, new environment
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
            presenter.loadABTest()
        }
    }
}

extension DevSettingsView {
    private var backButtonView: some View {
        Button(action: {
            presenter.onBackButtonPressed()
        }, label: {
            Image(systemName: "xmark")
        })
    }

    private var abtestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $presenter.createAccountTest)
                .onChange(of: presenter.createAccountTest, presenter.handleCreateAccountChange)

            Toggle("Onboarding Community Test", isOn: $presenter.onboardingCommunityTest)
                .onChange(of: presenter.onboardingCommunityTest, presenter.handleOnboardingCommunityChange)

            Picker("Category Row Test", selection: $presenter.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue).id(option)
                }
            }
            .onChange(of: presenter.categoryRowTest, presenter.handleCategoryRowTestChange)

            Picker("Paywall Test", selection: $presenter.paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue).id(option)
                }
            }
            .onChange(of: presenter.paywallTest, presenter.handlePaywallTestChange)

        } header: {
            Text("ABTest")
        }
        .font(.caption)
    }

    private var deviceInfoSection: some View {
        Section {
            ForEach(presenter.utilitiesData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }

    private var userInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            ForEach(presenter.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }

    private var authInfoSection: some View {
        Section {
            // 将字典转成数组, 因为这里的 Foreach 遍历需要有序
            ForEach(presenter.authData, id: \.key) { item in
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
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.devSettingsView(router: router)
    }
    .previewEnvironment()
}
