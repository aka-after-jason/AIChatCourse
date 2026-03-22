//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var isSvaing: Bool = false
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
        }
    }

    private var backButton: some View {
        Image(systemName: "xmark")
            .anyButton(.press) {
                onBackButtonPressed()
            }
    }

    private var nameSection: some View {
        Section {
            TextField("your name...", text: $avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }

    private var attributesSection: some View {
        Section {
            Picker("is a...", selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("that is...", selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("in the...", selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

        } header: {
            Text("Attributes")
        }
    }

    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .opacity(isGenerating ? 0.0 : 1.0)
                        .anyButton(.plain, action: { onGenerateImagePressed() })

                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1.0 : 0.0)
                }
                .disabled(isGenerating || avatarName.isEmpty)

                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            }
                        }
                    }
            }
            .removeListRowFormatting()
            .padding()
        }
    }

    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSvaing,
                title: "Save",
                action: onSavePressed
            )
            .removeListRowFormatting()
            .opacity(generatedImage == nil ? 0.5 : 1.0)
            .disabled(generatedImage == nil)
        }
    }

    private func onBackButtonPressed() {
        dismiss()
    }

    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            try? await Task.sleep(for: .seconds(3))
            generatedImage = UIImage(systemName: "star.fill")
            isGenerating = false
        }
    }

    private func onSavePressed() {
        isSvaing = true
        Task {
            try? await Task.sleep(for: .seconds(3))
            dismiss()
            isSvaing = false
        }
    }
}

#Preview {
    CreateAvatarView()
}
