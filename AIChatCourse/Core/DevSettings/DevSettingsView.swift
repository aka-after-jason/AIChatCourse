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
    var body: some View {
        // This is a sheet, new environment
        NavigationStack {
            List {
                authInfoSection
                userInfoSection
                deviceInfoSection
            }
            .navigationTitle("Dev Settings 🤗")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
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
            let array = userManager.currentUser?.eventParams.asAlphabeticalArray ?? []
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
            if let value = item.value as? String {
                Text(value)
            } else if let value = item.value as? Bool {
                Text(value.description)
            } else if let value = item.value as? Int {
                Text("\(value)")
            } else if let value = item.value as? Double {
                Text("\(value)")
            } else if let value = item.value as? Date {
                Text(value.formatted())
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
