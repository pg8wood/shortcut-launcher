//
//  MainViewController.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/10/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

enum ShortcutImportState {
    case notImported
    case loading
    case imported(shortcuts: [Shortcut])
    case error
}

class MainViewController: UIViewController, UINavigationControllerDelegate {
    
    var shortcutIntentState: ShortcutIntentState!
    var deepLinkHandler: DeepLinkHandler!
        
    var shortcutImportState: ShortcutImportState = .notImported {
        didSet {
            // TODO use a loading indicator or something to convey this state
            switch shortcutImportState {
            case .notImported:
                title = "Shortcut Setup"
                break
            case .loading:
                break
            case .imported(let shortcuts):
                self.shortcuts = shortcuts
                break
            case .error:
                break
            }
        }
    }

    var shortcuts: [Shortcut] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
    }
    
    @IBAction func didSelectInstallShortcutsButton(_ sender: UIButton) {
        func presentInstallShortcutsView() {
            let hostingController = UIHostingController(rootView: InstallShortcutsView())
            hostingController.title = "Install Shortcuts"
            
            navigationController?.pushViewController(hostingController, animated: true)
        }

        presentInstallShortcutsView()
    }
    
    @IBAction func didSelectMyShortcutsButton(_ sender: UIButton) {
        if shortcuts.isEmpty {
            ShortcutRunner.runShortcut(RequiredShortcut.importShortcuts.shortcut)
            shortcutImportState = .loading
        } else {
            presentMyShortcutsView()
        }
    }
    
    func presentMyShortcutsView() {
        let runnableShortcuts = shortcuts.filter {
            let packagedShortcutNames = RequiredShortcut.allCases.map({ $0.name })
            
            return !packagedShortcutNames.contains($0.name)
        }
        
        let contentView = ContentView(shortcuts: runnableShortcuts)
            .environmentObject(shortcutIntentState)
            .environmentObject(deepLinkHandler)
        let hostingController = UIHostingController(rootView: contentView)
        present(hostingController, animated: true)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let coordinator = navigationController.topViewController?.transitionCoordinator else {
            return
        }
        
        coordinator.notifyWhenInteractionChanges { (context) in
            if !context.isCancelled && viewController == self {
                AppConfig.isHeadTrackingEnabled = true
            }
        }
    }
}
