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
    
    @State private var presentTouchAlert = true
    
    var body: some View {
        ZStack {
            VStack {
                Text("Shortcut Launcher uses these shortcuts to interact with Siri Shortcuts.")
                List {
                    ForEach(installableShortcuts) { shortcut in
                        InstallShortcutListItem(shortcut: shortcut)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Spacer()
            }
            
            if presentTouchAlert {
                GazeEatingView()
            }
        }
        .alert(isPresented: self.$presentTouchAlert) {
            Alert(title: Text("Shortcut installation requires touch interaction in the Shortcuts app. You will lose head tracking."))
        }
        .navigationBarTitle("Install Shortcuts")
    }
}

struct InstallShortcutsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallShortcutsView()
    }
}
