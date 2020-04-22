//
//  InstallShortcutsView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InstallShortcutsView: View {
    private let requiredShortcuts = RequiredShortcut.allCases.map { $0.shortcut }
    private let exampleShortcuts = ExampleShortcut.allCases.map { $0.shortcut }
    
    @State private var presentTouchAlert = true
    
    var body: some View {
        ZStack {
            List {
                Text("For each shortcut you install, please run the shortcut at least using touch. Shortcuts will prompt you to accept permissions and/or set up the shortcut.")
                    .disabled(true)
                
                Section(header: Text("Required Shortcuts").font(.headline), footer: Text("Shortcut Launcher uses these shortcuts to interact with Siri Shortcuts. Make sure you do not edit the names of these shortcuts in the Shortcuts app.")) {
                    ForEach(requiredShortcuts) { shortcut in
                        InstallShortcutListItem(shortcut: shortcut)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Example Shortcuts").font(.headline), footer: Text("Shortcuts that show off how this all works. Maybe this footer could link to the website where we have a list of more example shortcuts.")) {
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
            Alert(title: Text("Shortcut installation requires touch interaction in the Shortcuts app. You will lose head tracking."))
        }
        .navigationBarTitle("Install Shortcuts", displayMode: .inline)
    }
}

struct InstallShortcutsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallShortcutsView()
    }
}
