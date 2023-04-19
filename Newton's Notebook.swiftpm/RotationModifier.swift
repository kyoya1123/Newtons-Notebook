//
//  RotationModifier.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/19.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action((UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)!)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
