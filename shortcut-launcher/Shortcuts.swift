//
//  Shortcut.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

class Shortcut: Identifiable {
    var id = UUID()
    var name: String
    var image: UIImage?
    
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
         image: UIImage? = nil,
         successDeepLink: DeepLink? = nil,
         cancelDeepLink: DeepLink? = nil,
         errorDeepLink: DeepLink? = nil) {
        self.name = name
        self.image = image
        
        defer {
            self.successDeepLink = successDeepLink
            self.cancelDeepLink = cancelDeepLink
            self.errorDeepLink = errorDeepLink
        }
    }
}

class UtilityShortcut: Shortcut {
    let description: String
    let installationURL: URL
    let systemImageName: String
    let iconColor: Color
    
    init(name: String,
         description: String,
         installationURL: URL,
         systemImageName: String,
         iconColor: Color,
         successDeepLink: DeepLink? = nil,
         cancelDeepLink: DeepLink? = nil,
         errorDeepLink: DeepLink? = nil) {
        self.description = description
        self.installationURL = installationURL
        self.systemImageName = systemImageName
        self.iconColor = iconColor
        super.init(name: name, successDeepLink: successDeepLink, cancelDeepLink: cancelDeepLink, errorDeepLink: errorDeepLink)
    }
}

enum PackagedShortcut: CaseIterable {
    case importShortcuts
    case proxyKeyboardInput
    case proxyChooseFromList
    
    var name: String {
        shortcut.name
    }
    
    // TODO: update iCloud URLs once the app name is chosen. Otherwise the old app name will display in the shortcut.
    // TODO does Cancel need a different deep link? Is cancel even possible for these shortcuts?
    var shortcut: UtilityShortcut {
        switch self {
        case .importShortcuts:
            return UtilityShortcut(name: "Get My Shortcuts",
                                   description: "Fetches the names of all the shortcuts installed on your device.",
                                   installationURL: URL(string: "https://www.icloud.com/shortcuts/5cfba321d82e4af99590de4c596fa909")!,
                                   systemImageName: "s.square",
                                   iconColor: .red,
                                   successDeepLink: .importShortcuts,
                                   cancelDeepLink: .needsToInstallGetMyShortcuts,
                                   errorDeepLink: .needsToInstallGetMyShortcuts)
        case .proxyKeyboardInput:
            return UtilityShortcut(name: "Proxy Input to Shortcut Launcher",
                                   description: "Opens Shortcut Launcher to respond to a shortcut's request for input.",
                                   installationURL: URL(string: "https://www.icloud.com/shortcuts/d28f6303dcba4e7aa9bcf7d3c453c955")!,
                                   systemImageName: "keyboard",
                                   iconColor: .pink)
        case .proxyChooseFromList:
            return UtilityShortcut(name: "Choose From List in Shortcut Launcher",
                                   description: "Opens Shortcut Launcher to choose from a list of options provided by a shortcut.",
                                   installationURL: URL(string: "https://www.icloud.com/shortcuts/a024b4981bc6412ab4c6ef7012d4233b")!,
                                   systemImageName: "list.bullet",
                                   iconColor: .blue)
        }
    }
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
