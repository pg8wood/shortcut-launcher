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
        // TODO: - wrap this up nicely in a SwiftUI View to avoid this hack
        // It's hacky. Would look way better wrapping the Main view in a SwiftUI host view and passing in the deepLinkHandler and shortcutIntentState as environemnt objects.
        func installMainViewControllerDependencies() {
            let trackingContainerViewController = headGazeWindow.rootViewController as! TrackingContainerViewController
            let navigationController = trackingContainerViewController.children[1] as! UINavigationController
            let mainViewController = navigationController.viewControllers[0] as! MainViewController
            mainViewController.deepLinkHandler = deepLinkHandler
            mainViewController.shortcutIntentState = shortcutIntentState
        }
        
         if let windowScene = scene as? UIWindowScene {
            AppConfig.isHeadTrackingEnabled = true
            UIApplication.shared.isIdleTimerDisabled = true
            headGazeWindow = HeadGazeWindow(frame: UIScreen.main.bounds) // TODO: as of now, this particular initializer MUST be called. Maybe do the setup stuff on its frame's didSet?
            headGazeWindow.windowScene = windowScene
            headGazeWindow.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.window = headGazeWindow
            headGazeWindow.makeKeyAndVisible()
            installMainViewControllerDependencies()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        deepLinkHandler.handleDeepLink(url, in: scene)
    }
    
    func presentContentView(in scene: UIScene, with shortcuts: [Shortcut] = []) {
        let trackingContainerViewController = headGazeWindow.rootViewController as! TrackingContainerViewController
        let navigationController = trackingContainerViewController.children[1] as! UINavigationController
        let mainViewController = navigationController.viewControllers[0] as! MainViewController
        
        mainViewController.shortcutImportState = .imported(shortcuts: shortcuts)
        mainViewController.presentMyShortcutsView()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let intent = userActivity.interaction?.intent else {
            return
        }
        
        IntentHandler.handleIntent(intent, with: shortcutIntentState)
    }
}
