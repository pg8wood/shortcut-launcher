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
        NavigationView {
            VStack(spacing: 32) {
                contentview
                    .sheet(isPresented: $shortcutIntentState.isRequestingUserInput, onDismiss: {
                        ShortcutRunner.openShortcuts()
                    }, content: {
                        ShortcutInputView()
                            .environmentObject(self.shortcutIntentState)
                    })
                
                Button(action: {
                    let invalidShortcut = Shortcut(name: "Shortcut that doesn't exist")
                    invalidShortcut.successDeepLink = .openApp
                    invalidShortcut.cancelDeepLink = .openApp
                    invalidShortcut.errorDeepLink = .openApp
                    ShortcutRunner.runShortcut(invalidShortcut)
                }, label: { Text("Open invalid Shortcut") })
                    .alert(isPresented: self.$showInvalidShortcutAlert) {
                        shortcutsErrorAlert
                }
                .onReceive(deepLinkHandler.$shortcutErrorMessage) { errorMessage in
                    self.showInvalidShortcutAlert = errorMessage != nil
                }
                
                NavigationLink(destination: InstallShortcutsView()) {
                    Text("Install Shortcuts")
                }
            }
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
                ShortcutRunner.runShortcut(PackagedShortcut.importShortcuts.shortcut)
            }, label: {
                Text("Import Shortcuts")
            })
            .alert(isPresented: $deepLinkHandler.needsToInstallGetMyShortcuts) {
                Alert(title: Text("Could Not Import Shortcuts"), message: Text("Please install the \"Get My Shortcuts\" shortcut to import your shortcuts."),
                      dismissButton: .default(Text("OK")) {
                        self.deepLinkHandler.needsToInstallGetMyShortcuts = false
                })
            }
            .navigationBarTitle("Import Your Shortcuts")
        )
    }
    
    private var shortcutsList: AnyView {
        AnyView (
            VStack {
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
            .navigationBarTitle("My Shortcuts")
            .padding()
        )
    }
    
    private var shortcutsErrorAlert: Alert {
        Alert(title: Text("Error Running Shortcut"),
              message: Text(self.deepLinkHandler.shortcutErrorMessage ?? "An unknown error occurred"),
              dismissButton: .default(Text("OK")) {
                self.deepLinkHandler.shortcutErrorMessage = nil
            })
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
