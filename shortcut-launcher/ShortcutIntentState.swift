//
//  ShortcutIntentState.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import Foundation

class ShortcutIntentState: ObservableObject {
    @Published var isRequestingUserInput: Bool = false
}
