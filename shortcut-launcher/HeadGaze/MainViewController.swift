//
//  MainViewController.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/10/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

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
    private var disposables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeGetMyShortcutsState()
    }
    
    private func observeGetMyShortcutsState() {
        guard disposables.isEmpty else {
            return
        }
        
        deepLinkHandler.$needsToInstallGetMyShortcuts.sink(receiveValue: { [weak self] needsToInstallGetMyShortcuts in
            guard needsToInstallGetMyShortcuts, let self = self else {
                return
            }
            
            let alert = UIAlertController(title: "Could Not Import Shortcuts",
                                          message: "Please install the \"Get My Shortcuts\" shortcut to import your shortcuts.\nDemo note: this alert is not gazeable.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Install Required Shortcuts", style: .default, handler: { [weak self] _ in
                self?.presentInstallShortcutsView()
            })
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
        }).store(in: &disposables)
    }
    
    private func presentInstallShortcutsView() {
        let hostingController = UIHostingController(rootView: InstallShortcutsView())
        hostingController.title = "Install Shortcuts"
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func didSelectInstallShortcutsButton(_ sender: UIButton) {
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
