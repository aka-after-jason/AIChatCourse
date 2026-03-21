//
//  ButtonViewModifier.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/3/21.
//

import SwiftUI

enum ButtonStyleOption {
    case plain, press, highlight
}

struct HighlightButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.accent.opacity(0.0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

extension View {
     
    @ViewBuilder // some View 需要返回一个具体的类型
    func anyButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .plain:
            self.plainButton(action: action)
        case .press:
            self.pressableButton(action: action)
        case .highlight:
            self.highlightButton(action: action)
        }
    }
    
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())

    }
}

#Preview {
    VStack {
        
        Text("Pressable Button")
            .callToActionButton()
            .anyButton(.press) {
                
            }
        
        Text("highlight button")
            .callToActionButton()
            .anyButton(.highlight) {
                
            }
        
       Text("Plain button")
            .callToActionButton()
            .anyButton(.plain) {
                
            }
        
        Text("default button")
            .callToActionButton()
            .anyButton {
                
            }

    }
    .padding()
}
