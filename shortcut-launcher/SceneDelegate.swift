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
        
        let trackingContainerViewController = headGazeWindow.rootViewController as! TrackingContainerViewController
        let mainViewController = trackingContainerViewController.children[1] as! MainViewController
        let hostingController = UIHostingController(rootView: contentView)
//        hostingController.modalPresentationStyle = .fullScreen
        mainViewController.present(hostingController, animated: true)
        //            self.window = window
        //            window.makeKeyAndVisible()
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let intent = userActivity.interaction?.intent else {
            return
        }
        
        IntentHandler.handleIntent(intent, with: shortcutIntentState)
    }
}
