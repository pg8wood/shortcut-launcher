//
//  InstallShortcutListItem.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InstallShortcutListItem: View {
    let shortcut: UtilityShortcut
    
    private let textHeight: CGFloat = 50
    private var imageHeight: CGFloat {
        2 / 3 * textHeight
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                self.header
                Text(shortcut.description)
                    .fontWeight(.light)
            }
        }
        .padding()
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: shortcut.systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageHeight, height: imageHeight)
                .foregroundColor(.white)
                .padding(8)
                .background(shortcut.iconColor)
                .cornerRadius(10)
            
            Text(shortcut.name)
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.leading)
                .frame(height: textHeight)
            
            Spacer()
            
            self.installButton
        }
    }
    
    private var installButton: some View {
        var background: some View {
            Capsule()
                .fill(Color.blue)
        }
        
        return Button(action: {
            UIApplication.shared.open(self.shortcut.installationURL)
        }, label: {
            Text("View")
                .foregroundColor(.white)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(background)
        })
    }
}

struct InstallShortcutListItem_Previews: PreviewProvider {
    static var previews: some View {
        InstallShortcutListItem(shortcut: PackagedShortcut.proxyKeyboardInput.shortcut)
    }
}
