//
//  Stage.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/17.
//

import SpriteKit

enum Stage: String, CaseIterable {
    case opening
    case stage1
    case stage2
    case stage3
    case stage4
    
    var scene: SKScene {
        SKScene(fileNamed: rawValue)!
    }

    var next: Stage? {
        switch self {
        case .opening:
            return .stage1
        case .stage1:
            return .stage2
        case .stage2:
            return .stage3
        case .stage3:
            return .stage4
        case .stage4:
            return nil
        }
    }
}
