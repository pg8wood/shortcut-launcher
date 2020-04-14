//
//  DeepLinkHandler.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit

enum DeepLink: String {
    case openApp = ""
    case importShortcuts = "importShortcuts"
    case needsToInstallGetMyShortcuts = "needsToInstallGetMyShortcuts"
    
    var fullURL: String {
        AppConfig.appURL + self.rawValue
    }
}

class DeepLinkHandler: ObservableObject {
    
    @Published var shortcutErrorMessage: String?
    @Published var needsToInstallGetMyShortcuts: Bool = false
    
    /// Handles a deep link, parsing URL query items in order.
    ///
    /// If multiple query items would trigger app navigation, only the first query item is resolved.
    func handleDeepLink(_ url: URL, in scene: UIScene) {
        guard url.scheme == AppConfig.appURLScheme,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            let sceneDelegate = (scene.delegate as? SceneDelegate) else {
                return
        }
        
        let deepLink = DeepLink(rawValue: urlComponents.host ?? "")
        
        // Handle Shortcuts-provided error message returned when trying to run an invalid shortcut. Don't handle `needsToInstallGetMyShortcuts`, as this type has its own error handling.
        func handleErrorMessageIfNeeded() {
            guard deepLink != .needsToInstallGetMyShortcuts else {
                return
            }
            
            if let errorMessage = queryItems.first(where: { $0.name == "errorMessage" }) {
                shortcutErrorMessage = errorMessage.value
            }
        }
        
        handleErrorMessageIfNeeded()
        
        switch deepLink {
        case .openApp:
            break
        case .importShortcuts:
            let shortcuts = shortcutNames(in: queryItems)
            
            if !shortcuts.isEmpty {
                sceneDelegate.presentContentView(in: scene, with: shortcuts)
            }
        case .needsToInstallGetMyShortcuts:
            needsToInstallGetMyShortcuts = true
        case .none:
            print(url.absoluteString)
            break
        }
    }
    
    private func shortcutNames(in queryItems: [URLQueryItem]) -> [String] {
        guard let shortcutNameResults = queryItems.first(where: { $0.name == "result" })?.value else {
                return []
        }
        
        return shortcutNameResults.components(separatedBy: "\n")
    }
}
