//
//  ShortcutIntentState.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import Foundation

enum IntentType {
    case askForInput
    case chooseFromList
}

class ShortcutIntentState: ObservableObject {
    @Published var isRequestingUserInput: Bool = false
    @Published var currentPrompt: String = ""
    @Published var choices: [String] = []
    
    var intentType: IntentType? = .askForInput
        
    func reset() {
        isRequestingUserInput = false
        currentPrompt = ""
        choices = []
        intentType = nil
    }
}
