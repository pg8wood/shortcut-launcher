//
//  Shortcut.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit

class Shortcut: NSObject, Identifiable {
    var id = UUID()
    var name: String
    
    // Deep links back into the app that will trigger according to the shortcut's return value.
    
    var successDeepLink: DeepLink? {
        didSet {
            xSuccessURL = "&x-success=\(successDeepLink?.fullURL ?? "")"
        }
    }
    
    var cancelDeepLink: DeepLink? {
        didSet {
            xCancelURL = "&x-cancel=\(cancelDeepLink?.fullURL ?? "")"
        }
    }
    
    var errorDeepLink: DeepLink? {
        didSet {
            xErrorURL = "&x-error=\(errorDeepLink?.fullURL ?? "")"
        }
    }
    
    // x-callback URLs. See: https://support.apple.com/en-au/guide/shortcuts/apdcd7f20a6f/ios
    private var xSuccessURL: String = ""
    private var xCancelURL: String = ""
    private var xErrorURL: String = ""
    
    private var urlEncodedName: String {
        name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var executionURL: URL {
        URL(string: "shortcuts://run-shortcut?name=\(urlEncodedName)\(xSuccessURL)\(xCancelURL)\(xErrorURL)")!
    }
    
    init(name: String,
         successDeepLink: DeepLink? = nil,
         cancelDeepLink: DeepLink? = nil,
         errorDeepLink: DeepLink? = nil) {
        self.name = name
        
        super.init()
        
        defer {
            self.successDeepLink = successDeepLink
            self.cancelDeepLink = cancelDeepLink
            self.errorDeepLink = errorDeepLink
        }
    }
}

struct UtilityShortcuts {
    // TODO diff urls for cancel
    static let getMyShortcuts = Shortcut(name: "Get My Shortcuts",
                                         successDeepLink: .importShortcuts)
}

struct ShortcutRunner {
    /// Opens the Shortcuts app.
    static func openShortcuts() {
        UIApplication.shared.open(URL(string: "shortcuts://")!)
    }
    
    /// Opens the Shortcuts app and runs a shortcut.
    static func runShortcut(_ shortcut: Shortcut) {
        UIApplication.shared.open(shortcut.executionURL)
    }
}
