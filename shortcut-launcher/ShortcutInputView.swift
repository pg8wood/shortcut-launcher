//
//  ShortcutInputView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ShortcutInputView: View {
    @EnvironmentObject var shortcutIntentState: ShortcutIntentState
    @State private var input: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                inputView
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing:
                Button("Cancel") {
                    self.sendInputToShortcuts(AppConfig.cancelShortcutIdentifier)
                }
            )
        }
    }
    
    private var inputView: AnyView {
        switch shortcutIntentState.intentType {
        case .askForInput:
            return AnyView(
                VStack {
//                    Text("Responding to Shortcuts")
//                        .font(.title)
//                        .padding(.bottom, 25)
                    TextField(shortcutIntentState.currentPrompt, text: $input, onCommit: {
                        self.sendInputToShortcuts(self.input)
                    }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .navigationBarTitle("Test")
                    Spacer()
            })
        case .chooseFromList:
            if shortcutIntentState.choices.isEmpty {
                return noChoicesErrorview
            } else {
                return AnyView(
                    VStack {
                        Text(shortcutIntentState.currentPrompt)
                            .font(.title)
                            .padding(.bottom, 25)
                        choicesView
                    }
                )
            }
        case .none:
            return noIntentTypeErrorView
        }
    }
    
    private var noIntentTypeErrorView: AnyView {
        AnyView(Text("Shortcuts has opened shortcut-handler with an invalid input type. Please try again."))
    }
    
    private var choicesView: some View {
        AnyView(
            List {
                ForEach(shortcutIntentState.choices, id: \.self) { choice in
                    Button(action: {
                        self.sendInputToShortcuts(choice)
                    }, label: { Text(choice) })
                }
            }
        )
    }
    
    private var noChoicesErrorview: AnyView {
        AnyView(
            VStack(spacing: 16) {
                Text("You have no choice... You must try again.")
                    .font(.headline)
                    .foregroundColor(.red)
                Text("Shortcuts has asked you to make a choice, but no choices were given. Make sure the \"Choose from List in shortcut-launcher\" action is given a List of items as input.")
            }
        )
    }
    
    private func sendInputToShortcuts(_ input: String) {
        UIPasteboard.general.string = input
        self.shortcutIntentState.reset()
    }
}

struct ShortcutInputView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutInputView()
            .environmentObject(ShortcutIntentState())
    }
}
