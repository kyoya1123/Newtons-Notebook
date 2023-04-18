//
//  ContentViewModel.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/14.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var isRightHanded: Bool
    @Published var isReadyToPlay = true
    @Published var showResult = false
    @Published var showGoalConfirm = false
    let retryAction = PassthroughSubject<Void, Never>()
    let addBallAction = PassthroughSubject<Void, Never>()
    let goNextAction = PassthroughSubject<Void, Never>()

    @Published var collectedItems = [Item]()

    init(isRightHanded: Bool) {
        self.isRightHanded = isRightHanded
    }

    func didTapPlay() {
        if isReadyToPlay {
            addBallAction.send()
        } else {
            retryAction.send()
        }
        isReadyToPlay.toggle()
    }

    func didTapGoNext() {
        isReadyToPlay = true
        goNextAction.send()
    }

    func showResultView(collectedItems: [Item]) {
        self.collectedItems = collectedItems
        showResult = true
    }
}
