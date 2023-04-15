//
//  ContentViewModel.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import Foundation

class ContentViewModel: ObservableObject {
    var didTapReset: (() -> Void)?

    func resetButtonTapped() {
        // Call the view controller's function via callback
        didTapReset?()
    }
}
