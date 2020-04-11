//
//  AppConfig.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import Foundation

struct AppConfig {
    static let appURL = "\(appURLScheme)://"
    
    static var appURLScheme: String {
        let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as! [AnyObject]
        let urlTypeDictionary = urlTypes.first as! [String: AnyObject]
        let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as! [AnyObject]
        
        return urlSchemes.first as! String
    }

    static let getMyShortcutsURL = URL(string: "https://www.icloud.com/shortcuts/a6669a9f0899499896457d30ff8ad4b8")!
}
