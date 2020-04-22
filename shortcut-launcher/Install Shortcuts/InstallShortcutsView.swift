//
//  InstallShortcutsView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InstallShortcutsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var presentTouchAlert = true
    
    private let requiredShortcuts = RequiredShortcut.allCases.map { $0.shortcut }
    private let exampleShortcuts = ExampleShortcut.allCases.map { $0.shortcut }
    
    var body: some View {
        ZStack {
            List {
                Section(header: requiredShortcutsSectionHeader) {
                    ForEach(requiredShortcuts) { shortcut in
                        InstallShortcutListItem(shortcut: shortcut)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: exampleShortcutsSectionHeader) {
                    ForEach(exampleShortcuts) { shortcut in
                        InstallShortcutListItem(shortcut: shortcut)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
            }
            .listStyle(GroupedListStyle())
            
            if presentTouchAlert {
                GazeEatingView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: self.$presentTouchAlert) {
            Alert(title: Text("Shortcut installation requires touch interaction in the Shortcuts app. You will lose head tracking if you continue."),
                  message: Text("Demo note: this alert is not gazeable."),
                  primaryButton: .destructive(Text("Continue")) {
                    AppConfig.isHeadTrackingEnabled = false
                },
                  secondaryButton: .cancel(Text("Back to safety")) {
                    self.presentationMode.wrappedValue.dismiss()
                })
        }
        .navigationBarTitle("Install Shortcuts", displayMode: .inline)
    }
    
    private var requiredShortcutsSectionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Required Shortcuts")
                .font(.headline)
            Text("These shortcuts send input to Shortcuts Launcher. Please install them to enable the example shortcuts below. Note that these shortcuts should not be run directly. Instead, use them when building your own shortcuts.")
        }
    }
    
    private var exampleShortcutsSectionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Example Shortcuts").font(.headline)
            Text("Try out some premade shortcuts that use the utility shortcuts you installed above.")
        }
    }
}

struct InstallShortcutsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallShortcutsView()
    }
}
