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
    
    private var headGazeWindow: HeadGazeWindow!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        presentContentView(in: scene)
        
        
        
         if let windowScene = scene as? UIWindowScene {
            UIApplication.shared.isIdleTimerDisabled = true
            headGazeWindow = HeadGazeWindow(frame: UIScreen.main.bounds) // TODO: as of now, this particular initializer MUST be called. Maybe do the setup stuff on its frame's didSet?
            headGazeWindow.windowScene = windowScene
            headGazeWindow.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.window = headGazeWindow
            headGazeWindow.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            let shortcuts = shortcutNames(in: context.url)
            
            if !shortcuts.isEmpty {
                
                presentContentView(in: scene, with: shortcuts)
                break
            }
        }
    }
    
    private func shortcutNames(in url: URL) -> [String] {
        guard url.scheme == "shortcut-launcher",
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let shortcutNameResults = queryItems.first(where: { $0.name == "result" })?.value else {
                return []
        }
        
        return shortcutNameResults.components(separatedBy: "\n")
    }
    
    private func presentContentView(in scene: UIScene, with shortcutNames: [String] = []) {
        let shortcuts = shortcutNames.map { Shortcut(name: $0) }
        let contentView = ContentView(shortcuts: shortcuts)
            .environmentObject(shortcutIntentState)
        
        let child = UIHostingController(rootView: contentView)
        let trackingContainerViewController = headGazeWindow.rootViewController as! TrackingContainerViewController
        let mainViewController = trackingContainerViewController.children[1] as! MainViewController
        mainViewController.showShortcutsList(shortcuts)
        //            self.window = window
        //            window.makeKeyAndVisible()
        
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
