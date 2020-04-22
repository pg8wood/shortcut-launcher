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
            guard let dictionaryQueryItem = queryItems.first(where: { $0.name == "shortcuts" })?.value,
                let shortcutDictionary: [String: String] = try? JSONDecoder().decode([String: String].self, from: Data(dictionaryQueryItem.utf8)) else {
                return
            }
            
            func decodeBase64Image(_ base64String: String) -> UIImage? {
                guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
                    return nil
                }
                
                return UIImage(data: data)
            }
            
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                let importedShortcuts = shortcutDictionary.map { Shortcut(name: $0.key, image: decodeBase64Image($0.value)) }
                
                DispatchQueue.main.async {
                    if !importedShortcuts.isEmpty {
                        sceneDelegate.presentContentView(in: scene, with: importedShortcuts)
                    }
                }
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

private extension String
{
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}
