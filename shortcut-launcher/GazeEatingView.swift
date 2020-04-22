//
//  GazeEatingView.swift
//  shortcut-launcher
//
//  Created by Patrick Gatewood on 4/14/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct GazeEatingView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GazeEatingUIView {
        return GazeEatingUIView()
    }
    
    func updateUIView(_ uiView: GazeEatingUIView, context: Context) {
        // Noting to do
    }
}
