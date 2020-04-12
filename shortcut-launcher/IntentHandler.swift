//
//  IntentHandler.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/12/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI
import Intents

struct IntentHandler {
        
    static func handleIntent(_ intent: INIntent, with shortcutIntentState: ShortcutIntentState) {
        func handleAskInShortcutLauncherIntent(_ intent: AskInShortcutLauncherIntent) {
            guard let prompt = intent.prompt, !prompt.isEmpty else {
                shortcutIntentState.isMissingIntentParameters = true
                return
            }
            
            shortcutIntentState.currentPrompt = prompt
            shortcutIntentState.intentType = .askForInput
        }
        func handleChooseFromListIntent(_ intent: ChooseFromListIntent) {
            guard let prompt = intent.prompt, !prompt.isEmpty,
                let choices = intent.list, !choices.isEmpty else {
                shortcutIntentState.isMissingIntentParameters = true
                return
            }
            
            shortcutIntentState.currentPrompt = prompt
            shortcutIntentState.choices = choices
            shortcutIntentState.intentType = .chooseFromList
        }
        
        shortcutIntentState.isRequestingUserInput = true
        
        switch intent {
        case let intent as AskInShortcutLauncherIntent:
            handleAskInShortcutLauncherIntent(intent)
        case let intent as ChooseFromListIntent:
            handleChooseFromListIntent(intent)
        default:
            break
        }
    }
}
