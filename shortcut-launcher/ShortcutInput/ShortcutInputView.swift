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
        ZStack {
            GazeEatingView()
            NavigationView {
                VStack {
                    inputView
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Responding to Shortcuts", displayMode: .inline)
                .navigationBarItems(trailing:
                    Button("Cancel") {
                        self.sendInputToShortcuts(AppConfig.cancelShortcutIdentifier)
                    }
                )
            }
        }
    }
    
    private var inputView: AnyView {
        switch shortcutIntentState.intentType {
        case .askForInput:
            return AnyView(
                VStack(alignment: .leading) {
                    Text(shortcutIntentState.currentPrompt)
                        .font(.headline)
                        .bold()
                    TextField("Enter your response", text: $input, onCommit: {
                        self.sendInputToShortcuts(self.input)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
            return AnyView(InputErrorView().environmentObject(self.shortcutIntentState))
        }
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
        let state = ShortcutIntentState()
        state.isRequestingUserInput = true
        state.currentPrompt = "Test prompt"
        state.intentType = .askForInput
        
        return ShortcutInputView()
            .environmentObject(state)
    }
}
