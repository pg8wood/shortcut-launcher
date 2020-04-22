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
            ZStack {
                contentview
                    .sheet(isPresented: $shortcutIntentState.isRequestingUserInput, onDismiss: {
                        ShortcutRunner.openShortcuts()
                    }, content: {
                        ShortcutInputView()
                            .environmentObject(self.shortcutIntentState)
                    })
                
                if showInvalidShortcutAlert {
                    GazeEatingView()
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
                Toggle("Return here when the shortcut completes", isOn: $returnToAppOnCompletion)
                List {
                    ForEach(shortcuts.sorted { $0.name < $1.name }) { shortcut in
                        self.shortcutListItem(shortcut)
                    }
                    
                    self.sampleInvalidShortcutListItem
                }
            }
            .navigationBarTitle("My Shortcuts")
            .padding()
        )
    }
    
    private var sampleInvalidShortcutListItem: some View {
        let invalidShortcut = Shortcut(name: "Shortcut that doesn't exist")
        invalidShortcut.successDeepLink = .openApp
        invalidShortcut.cancelDeepLink = .openApp
        invalidShortcut.errorDeepLink = .openApp
        
        return shortcutListItem(invalidShortcut)
            .foregroundColor(.red)
            .alert(isPresented: self.$showInvalidShortcutAlert) {
                shortcutsErrorAlert
            }
            .onReceive(deepLinkHandler.$shortcutErrorMessage) { errorMessage in
                self.showInvalidShortcutAlert = errorMessage != nil
            }
    }
    
    private func shortcutListItem(_ shortcut: Shortcut) -> some View {
        HStack(spacing: 16) {
            if shortcut.image != nil {
                Image(uiImage: shortcut.image!)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 8)
            }
            
            Button(action: {
                self.runShortcut(shortcut, returningtoAppOnCompletion: self.returnToAppOnCompletion)
            }, label: {
                Text(shortcut.name)
            })
        }
        .frame(height: 75)
        .listRowInsets(EdgeInsets())
    }
    
    private var shortcutsErrorAlert: Alert {
        Alert(title: Text(self.deepLinkHandler.shortcutErrorMessage ?? "An unknown error occurred"),
              dismissButton: .default(Text("OK")) {
                self.deepLinkHandler.shortcutErrorMessage = nil
            })
    }
    
    private func runShortcut(_ shortcut: Shortcut, returningtoAppOnCompletion: Bool) {
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
        ContentView(shortcuts: ["My first shortcut"].map {
            Shortcut(name: $0, image: UIImage(systemName: "s.square"))
        })
        .environmentObject(ShortcutIntentState())
        .environmentObject(DeepLinkHandler())
    }
}
