//
//  ContentView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var shortcutIntentState: ShortcutIntentState
    
    let shortcuts: [Shortcut]
    
    private let getMyShortcutsShortcut = Shortcut(name: "Get My Shortcuts")

    @State private var showInvalidShortcutAlert = false
    @State private var returnToAppOnCompletion = true
    
    var body: some View {
        contentview
            .sheet(isPresented: $shortcutIntentState.isRequestingUserInput, onDismiss: {
                ShortcutsExecution.openShortcuts()
            }, content: {
                ShortcutInputView()
                    .environmentObject(self.shortcutIntentState)
            })
    }
    
    private var contentview: AnyView {
        if shortcuts.isEmpty {
            return importShortcutsButton
        } else {
            return shortcutsList
        }
    }
    
    private var importShortcutsButton: AnyView {
        AnyView(
            Button(action: {
                self.runShortcut(self.getMyShortcutsShortcut)
            }, label: {
                Text("Import Shortcuts")
            })
        )
    }
    
    private var shortcutsList: AnyView {
        AnyView (
            VStack {
                Text("Select a Shortcut to run")
                    .font(.headline)
                Toggle("Return to app after shortcut completes", isOn: $returnToAppOnCompletion)
                List {
                    ForEach(shortcuts) { shortcut in
                        Button(action: {
                            self.runShortcut(shortcut)
                        }, label: {
                            Text(shortcut.name)
                        })
                        .alert(isPresented: self.$showInvalidShortcutAlert) {
                            Alert(title: Text("Invalid shortcut"), message: Text("The shortcut does not exist."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
            .padding()
        )
    }
    
    private func runShortcut(_ shortcut: Shortcut) {
        let shortcutLaunchSuccess = ShortcutsExecution.runShortcut(shortcut, returningToAppOnCompletion: returnToAppOnCompletion)
        self.showInvalidShortcutAlert = !shortcutLaunchSuccess
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(shortcuts: ["My first shortcut"].map { Shortcut(name: $0) })
    }
}
