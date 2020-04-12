//
//  InstallShortcutListItem.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/11/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InstallShortcutListItem: View {
    let systemImageName: String
    let shortcutName: String
    let description: String
    let iconColor: Color
    
    private let textHeight: CGFloat = 50
    private var imageHeight: CGFloat {
        textHeight / 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    self.header
                    Text(self.description)
                        .fontWeight(.light)
                }
            }
        }
        .padding()
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFill()
                .frame(width: imageHeight, height: imageHeight)
                .foregroundColor(.white)
                .padding(8)
                .background(iconColor)
                .cornerRadius(10)
            
            Text(shortcutName)
                .fontWeight(.bold)
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
            // install shortcut
        }, label: {

            Text("View Shortcut")
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
        InstallShortcutListItem(systemImageName: "paperclip",
                                shortcutName: "Test Shortcut with a long name",
                                description: "This shortcut will blow your mind through the power of magic.",
                                iconColor: Color(.systemBlue))
            
    }
}
