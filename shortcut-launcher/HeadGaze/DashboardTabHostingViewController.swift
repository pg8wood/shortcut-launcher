//
//  DashboardTabHostingViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

class DashboardTabHostingViewController: UIHostingController<AnyView> {
    
    private let shortcutIntentState = ShortcutIntentState()
    required init?(coder aDecoder: NSCoder) {
        let contentView = AnyView(ContentView(shortcuts: [])
            .environmentObject(shortcutIntentState))
        
        super.init(coder: aDecoder, rootView: contentView)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        guard segue.identifier == "ContentViewControllerSegue" else {
//            return
//        }
//
//        installRootView()
//    }
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

}
