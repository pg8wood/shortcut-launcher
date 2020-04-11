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
    
    var fullURL: String {
        AppConfig.appURL + self.rawValue
    }
}

class DeepLinkHandler {
    
    /// Handles a deep link, parsing URL query items in order.
    ///
    /// If multiple query items would trigger app navigation, only the first query item is resolved.
    static func handleDeepLink(_ url: URL, in scene: UIScene) {
        guard url.scheme == AppConfig.appURLScheme,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let sceneDelegate = (scene.delegate as? SceneDelegate) else {
                return
        }
        
        switch DeepLink(rawValue: urlComponents.host ?? "") {
        case .openApp:
            break
        case .importShortcuts:
            let shortcuts = shortcutNames(in: urlComponents.queryItems)
            
            if !shortcuts.isEmpty {
                sceneDelegate.presentContentView(in: scene, with: shortcuts)
            }
        case .none:
            print(url.absoluteString)
            break
        }
    }
    
    private static func shortcutNames(in queryItems: [URLQueryItem]?) -> [String] {
        guard let shortcutNameResults = queryItems?.first(where: { $0.name == "result" })?.value else {
                return []
        }
        
        return shortcutNameResults.components(separatedBy: "\n")
    }
}
