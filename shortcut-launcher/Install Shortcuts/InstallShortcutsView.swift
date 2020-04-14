//
//  InstallShortcutsView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InstallShortcutsView: View {
    let installableShortcuts = PackagedShortcut.allCases.map { $0.shortcut }
    
    var body: some View {
        VStack {
            Text("Shortcuts Launcher uses these shortcuts to interact with Siri Shortcuts.")
            List {
                ForEach(installableShortcuts) { shortcut in
                    InstallShortcutListItem(shortcut: shortcut)
                }
                 .listRowInsets(EdgeInsets())
            }
            
            Spacer()
        }
            
        .navigationBarTitle("Install Shortcuts")
    }
}

struct InstallShortcutsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallShortcutsView()
    }
}
