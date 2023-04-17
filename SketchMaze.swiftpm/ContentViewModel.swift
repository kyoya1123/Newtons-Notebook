//
//  ContentViewModel.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var showResult = false
    let retryAction = PassthroughSubject<Void, Never>()
    let addBallAction = PassthroughSubject<Void, Never>()
    let setupAction = PassthroughSubject<Void, Never>()

    @Published var collectedItems = [Item]()

    func didGoal() {
        isTextHidden = false
    }

    func didTapRetry() {
        retryAction.send()
    }

    func didTapAddBall() {
        addBallAction.send()
    }

    func setupScene() {
        setupAction.send()
    }

    func showResultView(collectedItems: [Item]) {
        self.collectedItems = collectedItems
        showResult = true
    }
}
