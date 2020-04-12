//
//  InputErrorView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/12/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct InputErrorView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Image(systemName: "slash.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width / 5)
                    .foregroundColor(.red)
                
                Text("Invalid Request")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("No prompt was given, or Shortcuts Launcher can't figure out which type of input the shortcut was asking for.")
        
                self.resolutionInfo
                    .frame(width: geometry.size.width, height: 400, alignment: .leading)
                    .padding(.top, 16)
//                    .background(Color.red)
            }
//            .listStyle(GroupedListStyle())
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    var resolutionInfo: some View {
        func sectionHeader(_ title: String) -> some View {
            Text(title)
                .font(.headline)
                .listRowInsets(EdgeInsets())
        }
        
        return List {
            Section(header: sectionHeader("Resolutions")) {
                directRunExplanationView
                Group {
                    Text("Check your shortcut's actions. Make sure you pass the right input to the") +
                        Text(" Shortcuts Launcher shortcut").bold().foregroundColor(.gray) +
                    Text(".")
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular) // enables grouped inset list style
        .padding(.horizontal, -16)
    }
    
    var directRunExplanationView: some View {
        NavigationLink(destination: InstallShortcutsView()) {
            Group {
                Text("Don't run the") +
                    Text(" Shortcuts Launcher shortcuts ").bold().foregroundColor(.gray) +
                Text("directly. Instead, use them in your own shortcuts.")
            }
        }
    }
}


struct InputErrorView_Previews: PreviewProvider {
    static var previews: some View {
        InputErrorView()
    }
}
