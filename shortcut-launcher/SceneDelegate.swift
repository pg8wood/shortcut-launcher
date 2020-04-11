//
//  SceneDelegate.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let shortcutIntentState = ShortcutIntentState()
    private let deepLinkHandler = DeepLinkHandler()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        presentContentView(in: scene)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        deepLinkHandler.handleDeepLink(url, in: scene)
    }
    
    func presentContentView(in scene: UIScene, with shortcutNames: [String] = []) {
        let shortcuts = shortcutNames.map { Shortcut(name: $0) }
        let contentView = ContentView(shortcuts: shortcuts)
            .environmentObject(shortcutIntentState)
            .environmentObject(deepLinkHandler)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let intent = userActivity.interaction?.intent else {
            return
        }
        
        switch intent {
        case let intent as AskInShortcutLauncherIntent:
            shortcutIntentState.isRequestingUserInput = true
            shortcutIntentState.currentPrompt = intent.prompt ?? ""
            shortcutIntentState.intentType = .askForInput
        case let intent as ChooseFromListIntent:
            let choices = intent.list ?? []
            
            shortcutIntentState.isRequestingUserInput = true
            shortcutIntentState.currentPrompt = intent.prompt ?? ""
            shortcutIntentState.choices = choices
            shortcutIntentState.intentType = .chooseFromList
        default:
            break
        }
    }
}
