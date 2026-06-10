//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/22.
//

import SwiftUI

struct CreateAvatarView: View {
    @State var presenter: CreateAvatarPresenter

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
                presenter.onBackButtonPressed()
            }
    }

    private var nameSection: some View {
        Section {
            TextField("your name...", text: $presenter.avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }

    private var attributesSection: some View {
        Section {
            Picker("is a...", selection: $presenter.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("that is...", selection: $presenter.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }

            Picker("in the...", selection: $presenter.characterLocation) {
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
                        .opacity(presenter.isGenerating ? 0.0 : 1.0)
                        .anyButton(.plain, action: { presenter.onGenerateImagePressed() })

                    ProgressView()
                        .tint(.accent)
                        .opacity(presenter.isGenerating ? 1.0 : 0.0)
                }
                .disabled(presenter.isGenerating || presenter.avatarName.isEmpty)

                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = presenter.generatedImage {
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
                isLoading: presenter.isSvaing,
                title: "Save",
                action: {
                    presenter.onSavePressed()
                }
            )
            .removeListRowFormatting()
            .opacity(presenter.generatedImage == nil ? 0.5 : 1.0)
            .disabled(presenter.generatedImage == nil)
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
