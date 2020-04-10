//
//  MainViewController.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/10/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

class MainViewController: UIViewController {
    private let getMyShortcutsShortcut = Shortcut(name: "Get My Shortcuts")
    private let shortcutIntentState = ShortcutIntentState()
    @IBOutlet weak var importButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func importButtonSelected(_ sender: UIButton) {
        ShortcutsExecution.runShortcut(getMyShortcutsShortcut, returningToAppOnCompletion: true)
    }
    
    func showShortcutsList(_ shortcuts: [Shortcut]) {
        let contentView = ContentView(shortcuts: shortcuts)
            .environmentObject(shortcutIntentState)
        
        let hostingController = UIHostingController(rootView: contentView)
        present(hostingController, animated: true)
    }
}
