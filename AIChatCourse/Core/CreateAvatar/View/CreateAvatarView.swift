//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct CreateAvatarView: View {
    @State var viewModel: CreateAvatarViewModel

    var body: some View {
        List {
            nameSection
            attributesSection
            imageSection
            saveSection
        }
        .navigationTitle("Create Avatar")
        .appearAnalyticsViewModifier(name: "CreateAvatarView")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
}

extension CreateAvatarView {
    private var backButton: some View {
        Image(systemName: "xmark")
            .anyButton(.press) {
                viewModel.onBackButtonPressed()
            }
    }

    private var nameSection: some View {
        Section {
            TextField("your name...", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }

    private var attributesSection: some View {
        Section {
            Picker("is a...", selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("that is...", selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("in the...", selection: $viewModel.characterLocation) {
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
                        .opacity(viewModel.isGenerating ? 0.0 : 1.0)
                        .anyButton(.plain, action: { viewModel.onGenerateImagePressed() })

                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1.0 : 0.0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)

                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
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
                isLoading: viewModel.isSvaing,
                title: "Save",
                action: {
                    viewModel.onSavePressed()
                }
            )
            .removeListRowFormatting()
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
            .disabled(viewModel.generatedImage == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.createAvatarView(router: router)
    }
    .previewEnvironment()
}
