//
//  ContentViewModel.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var isTextHidden = true
    let retryAction = PassthroughSubject<Void, Never>()
    let addBallAction = PassthroughSubject<Void, Never>()

    func didGoal() {
        isTextHidden = false
    }

    func didTapRetry() {
        retryAction.send()
    }

    func didTapAddBall() {
        addBallAction.send()
    }
}
