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
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    
    let shortcuts: [Shortcut]
    
    @State private var returnToAppOnCompletion = false
    @State private var showInvalidShortcutAlert = false
    
    var body: some View {
        VStack(spacing: 32) {
            contentview
                .sheet(isPresented: $shortcutIntentState.isRequestingUserInput, onDismiss: {
                    ShortcutRunner.openShortcuts()
                }, content: {
                    ShortcutInputView()
                        .environmentObject(self.shortcutIntentState)
                })
            
            Button(action: {
                var invalidShortcut = Shortcut(name: "I don't have a shortcut of this name")
                invalidShortcut.successDeepLink = .openApp
                invalidShortcut.cancelDeepLink = .openApp
                invalidShortcut.errorDeepLink = .openApp
                ShortcutRunner.runShortcut(invalidShortcut)
            }, label: { Text("Open invalid Shortcut") })
        }
        .onReceive(deepLinkHandler.$shortcutErrorMessage) { errorMessage in
            self.showInvalidShortcutAlert = errorMessage != nil
        }
        .alert(isPresented: self.$showInvalidShortcutAlert) {
            Alert(title: Text("Error Running Shortcut"), message: Text(self.deepLinkHandler.shortcutErrorMessage ?? "An unknown error occurred"), dismissButton: .default(Text("OK")))
        }
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
                ShortcutRunner.runShortcut(UtilityShortcuts.getMyShortcuts)
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
                            self.runShortcut(shortcut, returningtoAppOnCompletion: self.returnToAppOnCompletion)
                        }, label: {
                            Text(shortcut.name)
                        })
                    }
                }
            }
            .padding()
        )
    }
    
    private func runShortcut(_ shortcut: Shortcut, returningtoAppOnCompletion: Bool) {
        var shortcut = shortcut
        if returningtoAppOnCompletion {
            shortcut.successDeepLink = .openApp
            shortcut.cancelDeepLink = .openApp
            shortcut.errorDeepLink = .openApp
        }
        
        ShortcutRunner.runShortcut(shortcut)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(shortcuts: ["My first shortcut"].map { Shortcut(name: $0) })
    }
}
