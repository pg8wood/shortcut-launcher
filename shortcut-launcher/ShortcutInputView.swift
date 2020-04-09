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
        VStack {
            Text("Responding to Shortcuts")
                .font(.title)
            TextField(shortcutIntentState.currentPrompt ?? "Input", text: $input, onCommit: {
                UIPasteboard.general.string = self.input
                self.shortcutIntentState.reset()
            }).textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
        }
        .padding()
    }
}

struct ShortcutInputView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutInputView()
    }
}
