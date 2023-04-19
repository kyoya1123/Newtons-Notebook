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
    @Published var isPlayButtonHidden = false
    @Published var showResult = false
    @Published var showGoalConfirm = false
    let retryAction = PassthroughSubject<Void, Never>()
    let playAction = PassthroughSubject<Void, Never>()
    let goNextAction = PassthroughSubject<Void, Never>()

    @Published var collectedItems = [Item]()

    init(isRightHanded: Bool) {
        self.isRightHanded = isRightHanded
    }

    func didTapPlay() {
        if isReadyToPlay {
            playAction.send()
        } else {
            retryAction.send()
        }
        isReadyToPlay.toggle()
    }

    func didTapGoNext() {
        isReadyToPlay = true
        goNextAction.send()
    }

    func showResultView() {
        showResult = true
    }
}
