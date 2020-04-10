//
//  Shortcut.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit

struct Shortcut: Identifiable {
    var id = UUID()
    var name: String
}

struct ShortcutsExecution {
    /// Opens the Shortcuts app.
    static func openShortcuts() {
        UIApplication.shared.open(URL(string: "shortcuts://")!)
    }
    
    // TODO: use x-callback cancellation and failure to account for missing required shortcuts and general error handling
    /// Opens the Shortcuts app and runs a shortcut.
    static func runShortcut(_ shortcut: Shortcut, returningToAppOnCompletion: Bool) -> Bool {
        guard let urlEncodedShortcutName = shortcut.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return false
        }
        
        let runShortcutURL = URL(string: "shortcuts://run-shortcut?name=\(urlEncodedShortcutName)\(returningToAppOnCompletion ? "&x-success=shortcut-launcher://" : "")")!
        
        UIApplication.shared.open(runShortcutURL)
        return true
    }
}
